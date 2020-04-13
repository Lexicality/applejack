--
-- ~ Prop Protectoin ~
-- ~ Moonshine ~
--

-- My thanks to Spacetech for the original code.
-- This is a heavily modified version of Simple Prop Protection.
-- http://code.google.com/p/simplepropprotection

-- Settings
if (not sql.TableExists("ms_ppconfig")) then
	sql.Query("CREATE TABLE ms_ppconfig("..
				"enabled INTEGER NOT NULL, ".. -- Are we enabled?
				"cleanup INTEGER NOT NULL, ".. -- Should disconnected player's props be cleaned up?
				"delay INTEGER NOT NULL);" -- Cleanup delay
			 );
	sql.Query("INSERT INTO ms_ppconfig(enabled, cleanup, delay) VALUES(1, 1, 120);");
end
local config = sql.QueryRow("SELECT * FROM ms_ppconfig LIMIT 1");
if (not (config and config.enabled and config.cleanup and config.delay)) then
	ErrorNoHalt("["..os.date().."] Applejack Prop Protection: Config is corrupt!\n");
	config.enabled = 1;
	config.cleanup = 1;
	config.delay = 120;
end

local function SaveData()
	local str = "";
	for key, value in pairs(config) do
		str = str .. "," .. key .. "=" .. tostring(value);
	end
	sql.Query("UPDATE ms_ppconfig SET " .. str:sub(2) .. ";");
end

-- Convars to tell clients the settings
for name, value in pairs(config) do
	value = tonumber(value);
	config[name] = value;
	CreateConVar("ms_ppconfig_"..name, value, FCVAR_REPLICATED);
end

-- Adjustment of existing functions
if (cleanup) then
	if (not cleanup.oAdd) then
		cleanup.oAdd = cleanup.Add;
	end
	function cleanup.Add(ply, _, ent)
		if (IsValid(ent) and IsPlayer(ply) and ent.SetPPOwner) then
			ent:SetPPOwner(ply);
			ent:SetPPSpawner(ply);
		end
		cleanup.oAdd(ply, _, ent);
	end
end

-- Friends
if (not sql.TableExists("ms_ppfriends")) then
	sql.Query("CREATE TABLE ms_ppfriends(UID INTEGER PRIMARY KEY, Friends TEXT NOT NULL);");
end

-- Local Definitions
local disconnected = {}; -- Disconnected players
local weirdtraces = { -- Tool modes that can be right-clicked to link them
	wire_winch		= true;
	wire_hydraulic	= true;
	slider			= true;
	hydraulic		= true;
	winch			= true;
	muscle			= true;
};
local function checkConstrainedEntities(ply, ent)
	for _, ent in pairs(constraint.GetAllConstrainedEntities(ent)) do
		if (not GM:PlayerCanTouch(ply, ent)) then
			return false;
		end
	end
	return true;
end
local function deletePropsByUID(uid, name)
	for _, ent in pairs(ents.GetAll()) do
		local owner, name, UID = ent:GetPPOwner();
		if (UID == uid) then
			if (GM.Entities[ent]) then
				ent:SetPPOwner(NULL);
			else
				ent:Remove();
			end
		end
	end
	disconnected[uid] = nil;
	if (name) then
		player.NotifyAll(NOTIFY_GENERIC, "%s's props have been cleaned up.", name);
	end
end
local function physhandle(ply, ent)
	return IsValid(ent) and gamemode.Call("PlayerCanTouch", ply, ent);
end

-- Public functions

---
-- Deletes a player's props
-- @param ply The player whose props should be deleted
-- @param silent Whether the cleanup should be announced.
function GM:ClearProps(ply, silent)
	if (not IsPlayer(ply)) then
		return;
	end
	deletePropsByUID(ply:UniqueID(), (not silent) and ply:Name() or false);
end

-- Hooks
---
-- Called if a player can 'touch' an entity with the toolgun/physgun
-- @param ply The player in question
-- @param ent The entity in question
-- @return True if they can touch it, false if they can't.
function GM:PlayerCanTouch(ply, ent)
	if (config["enabled"] == 0  or
		ent:GetClass() == "worldspawn" or
		ent.SPPOwnerless) then
		return true;
	end
	local owner = ent:GetPPOwner()
	if (not owner and ent:GetClass() == "prop_physics") then
		ent:SetPPOwner(ply);
		ply:Notify("You now own this prop.", NOTIFY_GENERIC);
		return true
	elseif (ply:IsAdmin()) then
		-- Admins can pick up anything
		return true;
	elseif (owner == ply or (IsPlayer(ply) and IsPlayer(owner) and owner:IsPPFriendsWith(ply))) then
		return true;
	else
		return false;
	end
end
function GM:CanTool(ply, tr, mode, chained)
	-- Before we do anything, let's make it so people can point cameras at whatever they want.
	if (mode == "camera" or mode == "rtcamera") then
		return true;
	elseif (not self.BaseClass:CanTool(ply, tr, mode)) then -- Firstly, let's let sandbox decide if they can't do it
		return false;
	elseif (tr.HitWorld or not IsValid(tr.Entity)) then -- If sandbox says it's ok, we don't care about anything that's not an entity.
		return true;
	end
	local ent = tr.Entity;
	if (self.Entities[ent]) then
		return false;
	elseif (not gamemode.Call("PlayerCanTouch", ply, ent)) then
		return false;
	elseif (not chained) then
		if (mode == "nail") then
			local line = util.TraceLine({
				start = tr.HitPos,
				endpos = tr.HitPos + tr.Normal * 16,
				filter = ent
			});
			if (IsValid(line.Entity) and not gamemode.Call("CanTool", ply, line, mode, true)) then
				return false;
			end
		elseif (ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2)) then
			if (weirdtraces[mode]) then
				local line = util.TraceLine({
					start = tr.HitPos,
					endpos = tr.HitPos + tr.HitNormal * 16384,
					filter = ply
				});
				if (IsValid(line.Entity) and not gamemode.Call("CanTool", ply, line, mode, true)) then
					return false;
				end
			elseif (mode == "remover" and not checkConstrainedEntities(ply, ent)) then
				return false;
			end
		end
	elseif (IsValid(ent._Player) and not ply:IsAdmin()) then
		return false;
	elseif (mode ~= "remover" and not ply:IsAdmin()) then
		local class = ent:GetClass();
		if (class:find("camera") or class:find("vehicle") or ent:IsDoor()) then
			return false
		end
	end
	self:Log(EVENT_BUILD,"%s used %s on a %s",ply:Name(),mode,ent:GetClass());
	return true;
end;

-- Called when a player attempts to punt an entity with the gravity gun.
function GM:GravGunPunt(ply, ent)
	return physhandle(ply, ent) and (ply:IsAdmin() or ply:HasAccess("G"));
end

function GM:PhysgunPickup(ply, ent)
	if (not IsValid(ent)) then
		return false;
	elseif (not physhandle(ply, ent)) then
		return false
	elseif (ent.PhysgunPickup) then
		return ent:PhysgunPickup(ply);
	elseif (ent.PhysgunDisabled) then
		return false;
	elseif (self.Entities[ent]) then
		if (not ply:IsAdmin()) then
			return false;
		elseif (not string.find(ent:GetClass(), "prop_physics")) then
			return false;
		end
		-- Admins can pick up world physics props
		return true;
	elseif (ent:IsVehicle()) then
		local model = ent:GetModel();
		if (not (ply:IsAdmin() or model:find("chair") or model:find("seat"))) then
			return false;
		end
	elseif (ent:IsDoor()) then
		return false; -- physgunning doors always leads to trouble.
	elseif (ply:IsAdmin()) then
		if (ent:IsPlayer()) then
			if (ent:InVehicle()) then
				return false;
			end
			ent:SetMoveType(MOVETYPE_NOCLIP);
			ply._Physgunnin = true;
		end
		return true; -- Admins need to be able to pick stuff up.
	elseif (IsValid(ent._Player)) then -- Stop players grabbing ragdolls
		return false;
	elseif (ent:IsNPC()) then -- Don't want people picking up npcs, now do we?
		return false;
	elseif (ent:GetPos():Distance(ply:GetPos()) > self.Config["Maximum Pickup Distance"]) then
		return false; -- Stop people picking up things on the other side of the map!
	end
	-- Let's let sandbox have a go at them

	return self.BaseClass.PhysgunPickup(self, ply, ent)
end;

-- Called when a player attempts to drop an entity with the physics gun.
function GM:PhysgunDrop(player, entity)
	if (entity:IsPlayer()) then
		entity:SetMoveType(MOVETYPE_WALK);
		player._Physgunnin = false;
	end
end
function GM:OnPhysgunFreeze(weapon, phys, ent, ply)
	if (ent:IsVehicle() and not ply:IsAdmin()) then
		return false;
	end
	self.BaseClass.OnPhysgunFreeze(self, weapon, phys, ent, ply);
end

function GM:OnPhysgunReload(_, ply)
	local tr = ply:GetEyeTrace();
	if (IsValid(tr.Entity) and not gamemode.Call("PlayerCanTouch", ply, tr.Entity)) then
		return false;
	end
	return self.BaseClass.OnPhysgunReload(self, _, ply);
end;

function GM:GravGunPickupAllowed(ply, ent)
	if (not physhandle(ply, ent)) then
		return false;
	elseif (ent.GravGunPickupAllowed) then
		return ent:GravGunPickupAllowed(ply);
	end
	return true;
end

do
	--       --
	-- Hooks --
	--       --

	local function PlayerAuthed(ply, sid, uid)
		disconnected[uid] = nil;
		timer.Destroy("Prop Cleanup "..uid);
		local str = sql.QueryValue("SELECT Friends FROM ms_ppfriends WHERE UID = '" .. uid .. "';");
		if (not str or str == "") then
			ply._ppFriends = {};
			ply._ppInsert = true;
			return
		end
		local stat, res = pcall(util.JSONToTable, str);
		if (not stat) then
			ErrorNoHalt("Unable to decode ", ply:Name(), "'s ppfriends table: ", res, "\n");
			res = {};
		end
		ply._ppFriends = res;
	end
	local function PlayerInitialSpawn(ply)
		-- You wouldn't think this would happen but hey.
		if (not ply._ppFriends) then
			ply._ppFriends = {};
		end

		-- Keep names up to date.
		do
			local uid = ply:UniqueID();
			local name = ply:Name();
			for _, pl in pairs(player.GetAll()) do
				if (pl ~= ply and pl._ppFriends[uid]) then
					pl._ppFriends[uid] = name;
				end
			end
		end
		-- See who we know is online/offline
		local onlinec, offlinec = 0, 0;
		local online , offline  = {}, {};
		local pl;
		for uid, name in pairs(ply._ppFriends) do
			pl = player.Get(uid);
			if (pl) then
				onlinec = onlinec + 1;
				-- Keep names up to date
				ply._ppFriends[uid] = pl:Name();
				table.insert(online, ply);
			else
				offlinec = offlinec + 1;
				table.insert(offline, uid);
			end
		end
		-- Check if we actually have any friends to be told about
		if (onlinec == 0 and offlinec == 0) then
			return;
		end
		-- This could potentially overflow clients connecting if they have a rediculous
		--  number of prop protection friends and/or the server is very busy.
		-- TODO: See if it causes a problem and find a way of dragging it out if it does.
		umsg.Start("MS PPUpdate", ply);
		umsg.Char(0);
		umsg.Short(onlinec);
		for _, pl in pairs(online) do
			umsg.Entity(pl);
		end
		umsg.Short(offlinec);
		for _, uid in pairs(offline) do
			umsg.String(ply._ppFriends[uid]);
			umsg.Long(uid);
		end
		umsg.End();
	end

	local sqlqs, buffering = {}, false;
	local function PrePlayerSaveData()
		-- Buffer the SQLite queries
		sqlqs = {};
		buffering = true;
	end
	local function PlayerSaveData(ply)
		local stat, res = pcall(util.TableToJSON, ply._ppFriends);
		if (not stat) then
			ErrorNoHalt("Could not encode ", ply:Name(), "'s PP Friends table: ", res, "\n");
			return;
		end
		local q = "INSERT OR REPLACE INTO ms_ppfriends (UID, Friends)" ..
			"VALUES (" .. ply:UniqueID() .. ",'" .. res .. "');";
		if (buffering) then
			table.insert(sqlqs, q);
		else
			sql.Query(q);
		end
	end
	local function PostPlayerSaveData()
		sql.Begin();
		for _, q in pairs(sqlqs) do
			sql.Query(q);
		end
		sql.Commit();
		buffering = false;
	end
	local function PlayerDisconnected(ply)
		timer.Create("Prop Cleanup " .. ply:UniqueID(),
			config["delay"], 1, deletePropsByUID, ply:UniqueID(), ply:Name());
		disconnected[ply:UniqueID()] = true;
	end
	local function spawnHandler(ply, ent)
		ent:SetPPOwner(ply)
		ent:SetPPSpawner(ply)
	end
	local function AcceptStream(ply, handler, id)
		if (handler == "ppconfig") then
			return ply:HasAccess("s");
		end
	end
	hook.Add("PlayerAuthed",         "Mshine Prop Protection", PlayerAuthed);
	hook.Add("PlayerDisconnected",   "Mshine Prop Protection", PlayerDisconnected);
	hook.Add("PlayerInitialSpawn",   "MShine Prop Protection", PlayerInitialSpawn);
	hook.Add("PrePlayerSaveData",    "MShine Prop Protection", PrePlayerSaveData);
	hook.Add("PlayerSaveData",       "MShine Prop Protection", PlayerSaveData);
	hook.Add("PostPlayerSaveData",   "MShine Prop Protection", PostPlayerSaveData);
	hook.Add("PlayerSpawnedSENT",    "Mshine Prop Protection", spawnHandler);
	hook.Add("PlayerSpawnedVehicle", "Mshine Prop Protection", spawnHandler);
	hook.Add("AcceptStream",         "Mshine Prop Protection", AcceptStream);
end

local fakeplayer;
do
	local function Name(self)
		return self.name;
	end
	local function UniqueID(self)
		return self.uid;
	end
	local function IsValid(self)
		return true;
	end
	local function IsPlayer(self)
		return true;
	end
	function fakeplayer(uid, name)
		return {
			uid      = uid;
			name     = name;
			Name     = Name;
			UniqueID = UniqueID;
			IsValid  = IsValid;
			IsPlayer = IsPlayer;
		};
	end
end

-- Commands
GM:RegisterCommand{
	Command     = "ppfriends";
	Arguments   = "<Clear|Add|Remove> [Target]";
	Types       = "Phrase String";
	Hidden      = true;
	function(ply, action, target)
		-- Check if we've got a valid action
		if (action == "clear") then
			ply:ClearPPFriends();
			return true;
		end
		-- Get our victim
		if (not target) then
			return false, "No target specified!";
		end
		local victim = player.Get(target);
		if (not IsValid(victim)) then
			-- Make it so people can remove offline friends
			if (action == "remove") then
				-- But only using their UIDs
				--  (They shouldn't be using anything else but meh)
				target = tonumber[target];
				-- Verify they've used a valid UID
				if (target and ply._ppFriends[target]) then
					-- Make a fake player object to keep everyone happy
					--  (Unless someone tries to actually do something with it :D)
					victim = fakeplayer(target, ply._ppFriends[target]);
				else
					-- (Damn, exceptions would come in handy here.)
					return false, "Unable to find target '" .. target .. "'!";
				end
			else
				-- (Mainly to avoid this duplication.)
				return false, "Unable to find target '" .. target .. "'!";
			end
		end
		-- See what we're up to
		if (action == "add") then
			ply:AddPPFriend(victim);
			ply:Notify(victim:Name() .. " is now on your PP Friends list!", NOTIFY_GENERIC);
		else
			ply:RemovePPFriend(victim);
			ply:Notify(victim:Name() .. " is no longer on your PP Friends list!", NOTIFY_GENERIC);
		end
	end
};

GM:RegisterCommand{
	Command     = "ppcleardisconnected";
	Access      = "a";
	Hidden      = true;
	function()
		local _, uid;
		for _, ent in pairs(ents.GetAll()) do
			if (not IsValid(ent)) then
				continue;
			end
			_, _, uid = ent:GetPPOwner();
			if (not (uid and disconnected[uid])) then
				continue;
			elseif (GM.Entities[ent]) then
				ent:SetPPOwner(NULL);
			else
				ent:Remove();
			end
		end
	end
};

GM:RegisterCommand{
	Command     = "ppclearprops";
	Arguments   = "[Target]";
	Types       = "Player";
	Hidden      = true;
	function(ply, victim)
		if (not victim) then
			victim = ply;
		elseif (victim ~= ply and not ply:HasAccess("a")) then
			return false, "You do not have access to delete other people's props!";
		end
		deletePropsByUID(victim:UniqueID(), victim:Name());
	end
};

local function ppconfig(ply, _, _, _, upload)
	-- This really shouldn't be an issue but I don't trust datastream.
	if (not ply:HasAccess("s")) then
		ply:Notify("You do not have access to the prop protection config!", NOTIFY_GENERIC);
		return;
	end
	local n;
	-- Minimal exploit mode. Only looks for keys already extant in the config and only accepts numbers.
	for key in pairs(config) do
		n = tonumber(upload[key]);
		if (n) then
			config[key] = n;
			-- Notify everyone else
			game.ConsoleCommand("ms_ppconfig_" .. key .. " " .. n .. "\n");
		end
	end
end
datastream.Hook("ppconfig", ppconfig);

do
	local function s(p, r)
		p:PrintMessage(HUD_PRINTCONSOLE, r);
	end
	local a = "-- %-15s: %-68s --"
	local function f(p,b,c)
		p:PrintMessage(HUD_PRINTCONSOLE,string.format(a,b,c))
	end
	local b = "Vector(%09.4f, %09.4f, %09.4f)";
	local function makepos(a)
		return string.format(b,a.x,a.y,a.z);
	end
	local c = "Angle(%4i, %4i, %4i)";
	local function makeang(b)
		return string.format(c,b.p,b.y,b.r);
	end
	local function n(p, a)
		timer.Simple(0, _R.Player.Notify, p, a, 0);
	end
	local function cmd(p)
		local ent = p:GetEyeTrace().Entity
		if (not IsValid(ent)) then
			p:Notify("No entity.",0)
			return
		elseif not p:HasAccess("m") then
			p:Notify("You do not have access to that.",1)
			return
		end

		s(p, "-------------------------------------------------------------------------------------------");
		s(p, "--                                      Prop info                                        --");
		s(p, "-------------------------------------------------------------------------------------------");
		f(p, "Info", tostring(ent));
		f(p, "Model", '"'..ent:GetModel()..'"');
		local str = tostring( ent ).."["..ent:GetModel().."]";
		if (ent._POwner and ent._POwner ~= "" and ent._POwner ~= "World") then
			str = str .. "[" .. ent._POwner .. "]";
			f(p, "Owner", ent._POwner);
		end
		f(p, "Quick", str);
		n(p, str);
		s(p, "-------------------------------------------------------------------------------------------");
		if (ent:IsPlayer()) then
			s(p, "--                                     Player info                                       --");
			s(p, "-------------------------------------------------------------------------------------------");
			local name, sid, uid = ent:Name(), ent:SteamID(), ent:UniqueID()
			local str = "[" .. name .. "][" .. sid .. "][" .. uid .. "]"
			f(p, "Name", name )
			f(p, "SteamID", sid )
			f(p, "UniqueID", uid )
			local ug = ent:GetNWString("usergroup");
			if (ug ~= "") then
				f(p, "UserGroup", ug);
				str = str .. "[" .. ug .. "]";
			end
			n(p, str);
			f(p, "Quick", str )
			s(p, "-------------------------------------------------------------------------------------------");
		end
		s(p, "--                                     Other info                                        --");
		s(p, "-------------------------------------------------------------------------------------------");
		f(p, "Position", makepos(ent:GetPos()))
		f(p, "Angle",    makeang(ent:GetAngles()))
		local c = ent:GetColor()
		f(p, "Colour",     "Color("..c.r..", "..c.g..", "..c.b..", "..c.a..")");
		f(p, "Material",   tostring(ent:GetMaterial()));
		f(p, "Size",       tostring(ent:OBBMaxs() - ent:OBBMins()));
		f(p, "Radius",     tostring(ent:BoundingRadius()));
		local ph = ent:GetPhysicsObject();
		if (IsValid(ph)) then
			s(p, "-------------------------------------------------------------------------------------------");
			s(p, "--                                        PhysObj                                        --");
			s(p, "-------------------------------------------------------------------------------------------");
			f(p,"Mass",           tostring(ph:GetMass()));
			f(p,"Inertia",        tostring(ph:GetInertia()));
			f(p,"Velocity",       tostring(ph:GetVelocity()));
			f(p,"Angle Velocity", tostring(ph:GetAngleVelocity()));
			f(p,"Rot Damping",    tostring(ph:GetRotDamping()));
			f(p,"Speed Damping",  tostring(ph:GetSpeedDamping()));
		end
		s(p, "-------------------------------------------------------------------------------------------");
	end
	concommand.Add("sppa_info", cmd);
	concommand.Add("propinfo",  cmd);
end
