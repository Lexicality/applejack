--
-- ~ Database Functions ~
-- ~ Moonshine ~
--
local plymeta = _R.Player

local CHECK_FOR_PLAYERS = [[
	SHOW TABLES LIKE 'players';
]]
local CREATE_TABLE_PLAYERS = [[
	CREATE TABLE players (
		steamid64 BIGINT UNSIGNED PRIMARY KEY,
		data JSON,
		-- Data for manual table debugging
		steamid VARCHAR(255),
		lastname VARCHAR(255)
	);
]]
local NEW_PLAYER = [[
	INSERT INTO players SET steamid64 = ?, data = ?, steamid = ?, lastname = ?;
]]
local UPDATE_PLAYER = [[
	UPDATE players SET data = ?, lastname = ? WHERE steamid64 = ?;
]]
local LOAD_PLAYER = [[
	SELECT data FROM players WHERE steamid64 = ?;
]]

-- Some table values are set by the player and we need to pad them to prevent
-- them setting them to [0 0 0] or whatever to mess up the stupid json loader
player.freeTextKeys = {
	--
	_Clan = true,
}

GM.PendingQueries = {}

local function onConnected(db)
	GM:Log(EVENT_SQLDEBUG, "Connected to the MySQL server!")
	local tablequery = db:query(CHECK_FOR_PLAYERS)
	-- We need to know if the table exists before doing *anything* else
	tablequery:start()
	tablequery:wait(true)
	local err = tablequery:error()
	if err ~= "" then
		GM:Log(EVENT_ERROR, "Error checking the players table: %s", err)
		-- I dunno what to do here, so let's just break everything
		error(err)
	end
	if tablequery:affectedRows() == 0 then
		GM:Log(EVENT_SQLDEBUG, "Creating missing players table")
		local plyquery = db:query(CREATE_TABLE_PLAYERS)
		-- Literally can't start the server without a players table
		plyquery:start()
		plyquery:wait(true)
		if err ~= "" then
			GM:Log(EVENT_ERROR, "Error creating the players table: %s", err)
			error(err)
		end
	end
	-- Run all queries that came in while we were connecting to the database.
	-- TODO: If the database disconnects while we run these queries, everything will break
	for ply, func in pairs(GM.PendingQueries) do
		if IsValid(ply) then
			func(ply)
		end
	end
	GM.PendingQueries = {}
end
local function onConnectionFailed(db, err)
	GM:Log(EVENT_ERROR, "Error connecting to the MySQL server: %s", err)
	timer.Simple(
		10, function()
			GM:Log(EVENT_DEBUG, "Reconnecting to the MySQL server")
			GM:ConnectToDatabase()
		end
	)
end

function GM:ConnectToDatabase()
	GM:Log(EVENT_DEBUG, "Connecting to the MySQL server")
	if self.Database and self.Database:status() == mysqloo.DATABASE_CONNECTED then
		GM:Log(EVENT_SQLDEBUG, "Killing existing connection")
		self.Database:disconnect()
	end

	self.Database = mysqloo.connect(
		self.Config["MySQL Host"], self.Config["MySQL Username"],
		self.Config["MySQL Password"], self.Config["MySQL Database"]
	)

	self.Database.onConnected = onConnected
	self.Database.onConnectionFailed = onConnectionFailed

	self.Database:setAutoReconnect(true)
	self.Database:connect()
end

function GM:CanQueryDB()
	return self.Database and self.Database:status() == mysqloo.DATABASE_CONNECTED
end

local function returningPlayer(ply, row)
	local data = util.JSONToTable(row["data"])
	for key, data in pairs(data) do
		-- For user editable data we pad the field to prevent them turning it
		-- into a vector or something via Garry's magic roundabout JSON magic
		if GM.Config["User Editable Data"][key] then
			if not isstring(data) then
				-- Oops, we've clearly failed.
				data = tostring(data)
			else
				data = string.sub(data, 2, -2)
			end
		end
		ply.cider[key] = data
	end
	GM:Log(EVENT_DEBUG, "Loading of %s's data complete.", ply:Name())
	gamemode.Call("PlayerDataLoaded", ply, true)
end

local function newPlayer(ply)
	GM:Log(EVENT_DEBUG, "%s is new to the server. Data not loaded.", ply:Name())
	gamemode.Call("SetNewPlayerData", ply, ply.cider)
	gamemode.Call("PlayerDataLoaded", ply, false)
	ply:SaveData(true)
end

---
-- Load a player's data from the SQL database, overwriting any data already loaded on the player. Performs it's actions in a threaded query.
-- If the player's data has not been loaded after 30 seconds, it will call itself again
function plymeta:LoadData()
	if self._Initialized then
		return
	elseif not GM:CanQueryDB() then
		GM.PendingQueries[self] = function(ply)
			ply:LoadData()
		end
		return
	end
	-- Set up the default cider table.
	self.cider = {}
	gamemode.Call("SetPlayerDefaultData", self, self.cider)
	local query = GM.Database:prepare(LOAD_PLAYER)
	query:setString(1, self:SteamID64())
	query.self = self
	query.name = self:Name()
	query.onError = function(q, err, sql)
		GM:Log(EVENT_ERROR, "SQL Error loading %q's data: %s", q.name, err)
		-- TODO: 30s seems like a long time
		timer.Simple(
			30, function()
				if IsValid(self) then
					self:LoadData()
				end
			end
		)
	end
	query.onSuccess = function(q, data)
		if not IsValid(self) then
			return
		end
		if #data == 0 then
			newPlayer(self)
		else
			returningPlayer(self, data[1])
		end
	end
	query:start()
	self._LoadQuery = query
end

local function prepareData(ply, data)
	local toSave = {}
	for key, value in pairs(data) do
		if GM.Config["User Editable Data"][key] then
			value = "~" .. value .. "~"
		end
		-- TODO: Probably a hook for reading & writing these
		toSave[key] = value
	end
	return util.TableToJSON(toSave)
end

function plymeta:GetSaveQuery(create)
	gamemode.Call("PlayerSaveData", self)
	local data = prepareData(self, self.cider)
	local query
	if create then
		query = GM.Database:prepare(NEW_PLAYER)
		query:setString(1, self:SteamID64())
		query:setString(2, data)
		query:setString(3, self:SteamID())
		query:setString(4, self:Name())
	else
		query = GM.Database:prepare(UPDATE_PLAYER)
		query:setString(1, data)
		query:setString(2, self:Name())
		query:setString(3, self:SteamID64())
	end
	query.name = self:Name()
	return query
end

---
-- Save a player's data to the SQL server in a threaded query.
-- @param create Whether to create a new entry or do a normal update.
function plymeta:SaveData(create)
	if not self._Initialized then
		return
	end
	if not GM:CanQueryDB() then
		GM.PendingQueries[self] = function(ply)
			ply:SaveData(create)
		end
		return
	end
	local query = self:GetSaveQuery(create)
	-- GM:Log(EVENT_SQLDEBUG, "SQL Statement for %q: %s", query.name, q)
	function query:onError(err)
		GM:Log(EVENT_ERROR, "SQL Error in %q's save: %s", self.name, err)
	end
	function query:onSuccess()
		GM:Log(EVENT_SQLDEBUG, "SQL Statement successful for %q", self.name)
	end
	query:start()
	self._SaveQuery = query
end

---
--- Saves every player on the server's data.
function player.SaveAll()
	-- TODO: Transaction support
	gamemode.Call("PrePlayerSaveData")
	for _, ply in pairs(player.GetAll()) do
		ply:SaveData()
	end
	gamemode.Call("PostPlayerSaveData")
end
