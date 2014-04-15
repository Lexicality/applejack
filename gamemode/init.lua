--[[
Name: "init.lua".
	~ Applejack ~
--]]

-- Database module
require"mysqloo"

-- Include the shared gamemode file.
include("sh_init.lua")

-- Add the Lua files that we need to send to the client.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_enumerations.lua")
AddCSLuaFile("scoreboard/admin_buttons.lua")
AddCSLuaFile("scoreboard/player_frame.lua")
AddCSLuaFile("scoreboard/player_infocard.lua")
AddCSLuaFile("scoreboard/player_row.lua")
AddCSLuaFile("scoreboard/scoreboard.lua")
AddCSLuaFile("scoreboard/vote_button.lua")

-- Enable realistic fall damage for this gamemode.
game.ConsoleCommand("mp_falldamage 1\n")
game.ConsoleCommand("sbox_godmode 0\n")
game.ConsoleCommand("sbox_plpldamage 0\n")

-- Check to see if local voice is enabled.
if (GM.Config["Local Voice"]) then
	game.ConsoleCommand("sv_voiceenable 1\n")
	game.ConsoleCommand("sv_alltalk 1\n")
	game.ConsoleCommand("sv_voicecodec voice_speex\n")
	game.ConsoleCommand("sv_voicequality 5\n")
end

-- Some useful ConVars that can be changed in game.
CreateConVar("cider_ooc", 1)

-- Conetents
--[[
local path = GM.Folder.."/content"
local folders = {""}
while true do
	local curdir = table.remove(folders,1)
	if not curdir then break end
	local searchdir = path..curdir
	local files, folders = file.Find(searchdir.."/*", "MOD")
	for _, filename in ipairs(files) do
		resource.AddSingleFile(string.sub(curdir.."/"..filename, 2))
	end

	for _, filename in ipairs(folders) do
		if filename ~= ".svn" then
			table.insert(folders,curdir.."/"..filename)
		end
	end
end
--]]

local hook,player,umsg,pairs,ipairs,string,timer,IsValid,table,math =
	  hook,player,umsg,pairs,ipairs,string,timer,IsValid,table,math

do
	-- Store the old hook.Call function.
	local hookCall = hook.Call

	-- Overwrite the hook.Call function.
	function hook.Call(name, gm, ply, text, ...) -- the wonders of lau :v:
		if (name == "PlayerSay") then text = string.Replace(text, "$q", "\"") end

		-- Call the original hook.Call function.
		return hookCall(name, gm, ply, text, ...)
	end
	local m = FindMetaTable("Player")
	if m then
		function m:mGive(class)
			local w = ents.Create(class)
			w:SetPos(self:GetPos() + Vector(0,0,30))
			w:Spawn()
		end
	end
	local d = numpad.Deactivate
	function numpad.Deactivate(p,...)
		if not IsValid(p) then return end
		d(p,...)
	end
end

-- A table that will hold entities that were there when the map started.
GM.Entities = {}

local function onConnected()
	GM:Log(EVENT_SQLDEBUG,"Connected to the MySQL server!");
	for _, ply in pairs(player.GetAll()) do
		ply:SaveData();
	end
end
local function onFailure(q, err)
	GM:Log(EVENT_ERROR,"Error connecting to the MySQL server: %s", err);
	timer.Simple(60, GM.Database.connect, GM.Database);
end


-- Called when the server initializes.
function GM:Initialize()
	GM = self; -- ¬_¬ garru
	ErrorNoHalt"----------------------\n"
	ErrorNoHalt(os.date().." - Server starting up\n")
	ErrorNoHalt"----------------------\n"
	local hostname = self.Config["MySQL Host"]
	local username = self.Config["MySQL Username"]
	local password = self.Config["MySQL Password"]
	local database = self.Config["MySQL Database"]

	-- Initialize a connection to the MySQL database.
	self.Database = mysqloo.connect(hostname, username, password, database);
	self.Database:connect();

	-- Call the base class function.
	return self.BaseClass:Initialize()
end

---
-- Checks to see if the database is in a queryable state, and re-connects if it's not.
-- TODO: This URGENTLY needs a query queue system.
-- @return True if a query can be executed right now
function GM:CanQueryDB()
	local stat = self.Database:status();
	if (stat == mysqloo.DATABASE_CONNECTED) then
		return true;
	elseif (stat ~= mysqloo.DATABASE_CONNECTING) then
		self.Database:connect();
	end
	return false;
end

--WELL DONE MR DA DECO MAN. - Adding this as GM:AcceptStream DOES NOT WORK
--Called when a client streams at the server (try not to cross)
function AcceptStream ( pl, handler, id )
	--MsgN(string.format("Incoming datastream from %s with handler %s and id %s",pl:Name(),handler,id))
	if table.HasValue(GM.Config["Acceptable Datastreams"],handler) then
		return true
	else
		return false
	end
end
hook.Add( "AcceptStream", "AcceptStream", AcceptStream )

-- Called when all of the map entities have been initialized.
function GM:InitPostEntity()
	local count = 0;
	for _, ent in pairs(ents.GetAll()) do
		if (ent:IsDoor()) then
			ent:MakeOwnable();
			doors.Load(ent)
		end
		self.Entities[ent] = ent;
		count = count + 1;
		ent:SetPPOwner(NULL);
	end
	MsgN("=========================================================");
	MsgN("Map finished loading with ", count, " entities active.");
	MsgN("=========================================================");
	-- Tell plugins to load their datas a frame after this.
	timer.Simple(0,hook.Call,"LoadData",self);
	-- Inform anything loaded after this that it's not going to get an InitPostEntity call.
	self.Inited = true;
	-- Call the base class function.
	return self.BaseClass:InitPostEntity()
end

-- TODO: Move this stuff into the sv_player hooks
-- Called when a player attempts to arrest another player.
function GM:PlayerCanArrest(ply, target)
	if (target._Warranted == "arrest") then
		return true
	else
		ply:Notify(target:Name().." does not have an arrest warrant!", 1)
		-- Return false because the target does not have a warrant.
		return false
	end
end

-- Called when a player attempts to unarrest a player.
function GM:PlayerCanUnArrest(ply, target)
	return true
end

-- Called when a player attempts to spawn an NPC.
function GM:PlayerSpawnNPC(ply, model)
	if hook.Call("PlayerCanDoSomething",GAMEMODE,ply,nil,true) and (ply:IsSuperAdmin() or ply:HasAccess("N")) then
		GM:Log(EVENT_SUPEREVENT,"%s spawned a %q",ply:Name(),model)
		return true
	else
		return false
	end
end

function GM:PropSpawned(model,ent)
	local data = self.Config["Spawnable Containers"][model:lower()]
	if not data then return false end
	cider.container.make(ent,data[1],data[2])
	return true
end

function GM:PlayerSpawnedProp(ply,mdl,ent)
	ply._NextSpawnProp = CurTime() + 1;
	GM:Log(EVENT_BUILD, "%s spawned a %q", ply:Name(), mdl)
	if hook.Call("PropSpawned",GAMEMODE,mdl,ent) then
		ent:MakeOwnable();
		ent:GiveToPlayer(ply);
	end
	self.BaseClass:PlayerSpawnedProp(ply, mdl, ent);
end

-- To avoid redundancy.
function GM:PlayerCanSpawnProp(ply, mdl)
	-- Obligitory check
	local time = CurTime();
	if (not gamemode.Call("PlayerCanDoSomething", ply, nil, true)) then
		return false;
	elseif (ply:IsAdmin()) then
		return true;
	elseif ((ply._NextSpawnProp or 0) > time) then
		ply:Notify("You must wait " .. math.ceil(ply._NextSpawnProp - time) .. " second(s) before spawning another prop!", 1);
		return false;
	end
	-- Get the model into one sane string
	mdl = mdl:lower():gsub("[/\\]+","/");
	if (not util.IsValidModel(mdl)) then
		ply:Notify("Invalid model specified.", 1);
		return false;
	elseif (ply:GetCount("props") > self.Config["Prop Limit"]) then
		ply:Notify("Prop limit reached!", 1);
		return false;
	end
	for _, banned in pairs(self.Config["Banned Props"]) do
		if (mdl == banned) then
			ply:Notify("This prop is banned!", 1);
			return false;
		end
	end
	local ent = ents.Create("prop_physics")
	ent:SetModel(mdl)
	local radius = ent:BoundingRadius()
	ent:Remove()
	ent = nil
	if (radius > 100 and not ply:HasAccess("e")) --Only donators go above 100
	or (radius > 200 and not ply:IsModerator()) --Only mods go above 200
	or (radius > 300) then --Only admins go above 300.
		ply:Notify("That prop is too big for you to spawn!",1);
		return false;
	end
	return true;
end

-- Called when a player attempts to spawn a prop.
function GM:PlayerSpawnProp(ply, model)
	return (ply:IsAdmin() or ply:HasAccess("e")) and gamemode.Call("PlayerCanSpawnProp", ply, model);
end

-- Called when a player attempts to spawn a ragdoll.
function GM:PlayerSpawnRagdoll(ply, model)
	if hook.Call("PlayerCanDoSomething",GAMEMODE,ply,nil,true) and ply:IsAdmin() then
		GM:Log(EVENT_BUILD,"%s spawned a %q",ply:Name(),model)
		return true
	else
		return false
	end
end

-- Called when a player attempts to spawn an effect.
function GM:PlayerSpawnEffect(ply, model)
	if hook.Call("PlayerCanDoSomething",GAMEMODE,ply,nil,true) and ply:IsAdmin() then
		GM:Log(EVENT_BUILD,"%s spawned a %q",ply:Name(),model)
		return true
	else
		return false
	end
end

function GM:PlayerCanDoSomething(ply,ignorealive,spawning)
	if	(not ply:Alive() and not ignorealive) or
		ply:Arrested()		or
		ply:KnockedOut()	or
		ply:Tied()			or
		ply._Stunned		or
		ply._HoldingEnt		or
		ply._Equipping		or
		ply._StuckInWorld	or
		spawning and (ply:InVehicle() --[[or other places they shouldn't spawn shit]])  then
			ply:Notify("You cannot do that in this state!", 1)
			-- Return false because we cannot do it
			return false
	else
		return true
	end
end
-- Called when a player attempts to spawn a vehicle.
function GM:PlayerSpawnVehicle(ply, model, name, vtable)
	if not hook.Call("PlayerCanDoSomething",GAMEMODE,ply,nil,true) then return false
	elseif ply:IsSuperAdmin() then
		GM:Log(EVENT_SUPEREVENT,"%s spawned a %s with model %q",ply:Name(),name,model)
		return true
	end
	-- Check if the model is a chair.
	if ( not string.find(model, "chair") and not string.find(model, "seat") ) then
		ply:Notify("You must buy your car from the store!", 1)
		return false
	end
	if ( not ply:HasAccess("e") ) then return false end
	GM:Log(EVENT_BUILD,"%s spawned a %s with model %q",ply:Name(),name,model)
	-- Check if the player is an administrator.
	if ( ply:IsAdmin() ) then return true end

	-- Call the base class function.
	return self.BaseClass:PlayerSpawnVehicle(ply, model)
end

--[[function GM:PlayerSpawnedVehicle(player, entity)
	if (!IsValid(player._Vehicle)) then player._Vehicle = entity end
end]]

---
-- A function to check whether we're running on a listen server.
-- @return The listen server host if we are, false if we're not.
function GM:IsListenServer()
	if (self.ListenServer ~= nil) then
		return self.ListenServer;
	end
	self.ListenServer = false;
	for k, v in pairs( player.GetAll() ) do
		if (v:IsListenServerHost()) then
			self.ListenServer = v;
		end
	end
	if ( SinglePlayer() ) then
		self.ListenServer = Entity(1);
	end
	return self.ListenServer
end


--Called when a player connectsf
function GM:PlayerConnect(name,ip,steamID)
	print(string.format("Player connected %q, (%s): %s,",name,ip,steamID))
end

-- Called when the player has initialized.
function GM:PlayerInitialized(ply)
	if (ply.cider._Donator and ply.cider._Donator > 0) then
		local expire = math.max(ply.cider._Donator - os.time(), 0)

		-- Check if the expire time is greater than 0.
		if (expire > 0) then
			local days = math.floor( ( (expire / 60) / 60 ) / 24 )
			local hours = string.format("%02.f", math.floor(expire / 3600))
			local minutes = string.format("%02.f", math.floor(expire / 60 - (hours * 60)))
			local seconds = string.format("%02.f", math.floor(expire - hours * 3600 - minutes * 60))

			-- Give them their access.
			ply:GiveAccess("tpew")

			-- Check if we still have at least 1 day.
			if (days > 0) then
				ply:Notify("Your Donator status expires in "..days.." day(s).")
			else
				ply:Notify("Your Donator status expires in "..hours.." hour(s) "..minutes.." minute(s) and "..seconds.." second(s).")
			end

			-- Set some Donator only player variables.
			ply._SpawnTime = self.Config["Spawn Time"] / 2
			ply._KnockOutTime = self.Config["Knock Out Time"] / 2
		else
			ply.cider._Donator = 0

			-- Take away their access and save their data.
			ply:TakeAccess("tpew")
			ply:SaveData();

			-- Notify the player about how their Donator status has expired.
			ply:Notify("Your Donator status has expired!", 1)
		end
	end
	-- Give them back their shizzle
	self:RestoreAccess(ply);
	-- Make the player a Citizen to begin with.
	ply:JoinTeam(TEAM_DEFAULT)
	GM:Log(EVENT_PUBLICEVENT,"%s finished connecting.",ply:Name())
end

-- Called when a player's data is loaded.
function GM:PlayerDataLoaded(ply, success)
	ply._Salary					= 0;
	ply._JobTimeLimit			= 0;
	ply._JobTimeExpire			= 0;
	ply._LockpickChance			= 0;
	ply._CannotBeWarranted		= 0;
	ply._ScaleDamage			= 1;
	ply._Details				= "";
	ply._NextSpawnGender		= "";
	ply._NextSpawnGenderWord	= "";
	ply._Ammo					= {};
	ply. ragdoll				= {};
	ply._NextUse				= {};
	ply._NextChangeTeam			= {};
	ply._GunCounts				= {};
	ply._StoredWeapons			= {};
	ply._FreshWeapons			= {};
	ply. CSVars					= {}; -- I am aware that this is without a _, but I don't think it looks right with one.
	ply. tying                  = {}; -- Fuck _s. ~Lex 21/04/11
	ply._Initialized			= true;
	ply._UpdateData				= false;
	ply._Sleeping				= false;
	ply._Stunned				= false;
	ply._Tripped				= false;
	ply._Warranted				= false;
	ply._LightSpawn				= false;
	ply._ChangeTeam				= false;
	ply._HideHealthEffects		= false;
	ply._GenderWord				= "his";
	ply._Gender					= "Male";
	ply._NextOOC				= CurTime();
	ply._NextAdvert				= CurTime();
	ply._NextDeploy				= CurTime();
	-- Some player variables based on configuration.
	ply._SpawnTime				= self.Config["Spawn Time"];
	ply._ArrestTime				= self.Config["Arrest Time"];
	ply._Job					= self.Config["Default Job"];
	ply._KnockOutTime			= self.Config["Knock Out Time"];
	ply._IdleKick				= CurTime() + self.Config["Autokick time"];

	-- Call a hook for the gamemode.
	hook.Call("PlayerInitialized",GAMEMODE, ply)

	ply:SetNWString("Job", ply._Job);
	ply:SetNWString("Clan", ply.cider._Clan);
	ply:SetNWString("Details",ply._Details);
	ply:SetNWBool("Donator",ply.cider._Donator > 0);
	ply:SetNWBool("Moderator", ply:IsUserGroup("operator") or ply:IsUserGroup("moderator") or (evolve and ply:EV_GetRank() == "moderator") or (citrus and citrus.Player.GetGroup(ply).Name == "Moderators"));


	-- Respawn them now that they have initialized and then freeze them.
	ply:Spawn()
	ply:Freeze(true)
	-- Unfreeze them in a few seconds from now.
	-- TODO: WHY?
	timer.Simple(2, function()
		if ( IsValid(ply) ) then
			-- Check if the player is arrested.
			if (ply.cider._Arrested) then
				ply:Arrest();
			end
			ply:Freeze(false)
			-- We can now start updating the player's data.
			ply._UpdateData = true

			-- Send a user message to remove the loading screen.
			umsg.Start("cider.player.initialized", ply) umsg.End()
		end
	end)
end


local function inittimer(ply)
	ply._Timeout = ply._Timeout or 0
	ply._Timeout = ply._Timeout + 1
	if ply._Timeout <= 300 then
		GM:PlayerInitialSpawn(ply)
	else
		error("player timeout in PlayerInitialSpawn()")
	end
end
local function modeltimer(ply)
	if IsValid(ply) then
		umsg.Start("cider_ModelChoices",ply)
		umsg.Short(table.Count(ply._ModelChoices))
		for name,gender in pairs(ply._ModelChoices) do
			umsg.String(name)
			umsg.Short(#gender)
			for team,choice in ipairs(gender) do
				umsg.Short(team)
				umsg.Short(choice)
			end
		end
		umsg.End()
		datastream.StreamToClients(ply, "cider_Laws",cider.laws.stored) -- The laws has been updating bro
	end
end
-- Called when a player initially spawns.
function GM:PlayerInitialSpawn(ply)
	if (not IsValid(ply)) then
		timer.Simple(0.2, inittimer, ply);
		return;
	end
	ply:LoadData();

	ply._ModelChoices = {}
	for _,team in pairs(self.Teams) do
		for gender,models in pairs(team.Models) do
			ply._ModelChoices[gender] = ply._ModelChoices[gender] or {}
			if #models ~= 1 then
				ply._ModelChoices[gender][team.TeamID] = math.random(1,#models)
			else
				ply._ModelChoices[gender][team.TeamID] = 1
			end
		end
	end
	timer.Simple(0.2,modeltimer,ply)
	-- A table to store every contraband entity.
	local contraband = {}

	-- Loop through each contraband class.
	for k, v in pairs( self.Config["Contraband"] ) do
		table.Add( contraband, ents.FindByClass(k) )
	end

	-- Loop through all of the contraband.
	for k, v in pairs(contraband) do
		if (ply:UniqueID() == v._UniqueID) then v:SetPlayer(ply) end
	end

	-- Kill them silently until we've loaded the data.
	ply:KillSilent()
end

-- Called every frame that a player is dead.
function GM:PlayerDeathThink(ply)
	if (not ply._Initialized) then return true end

	-- Check if the player is a bot.
	if (ply:SteamID() == "BOT") then
		if (ply.NextSpawnTime and CurTime() >= ply.NextSpawnTime) then ply:Spawn() end
	end

	-- Return the base class function.
	return self.BaseClass:PlayerDeathThink(ply)
end

-- Called when a player's salary should be adjusted.
function GM:PlayerAdjustSalary(ply)
	if (ply.cider._Donator and ply.cider._Donator > 0) then
		ply._Salary = (ply._Salary or 1) * 2
	end
end

-- Called when a player's radio recipients should be adjusted.
function GM:PlayerAdjustRadioRecipients(ply, text, recipients)
end

-- Called when a player attempts to join a gang
function GM:PlayerCanJoinGang(ply,teamID,gangID)
end
-- Called when a player should gain a frag.
function GM:PlayerCanGainFrag(ply, victim) return true end

-- Called when a player's model should be set.
function GM:PlayerSetModel(ply)
	if ply.cider._Misc.custommodel and ply.cider._Misc.custommodel[ply:Team()] then
		ply:SetModel(ply.cider._Misc.custommodel[ply:Team()])
		return true
	end
	local models = ply:GetTeam().Models;--team.Query(ply:Team(), "Models")

	-- Check if the models table exists.
	if (models) then
		models = models[ply._Gender]

		-- Check if the models table exists for this gender.
		if (models) then
			local model = models[ ply._ModelChoices[ply._Gender][ply:Team()] ];
			ply:SetModel(model);
		end
	end
end

-- Called when a player spawns.
function GM:PlayerSpawn(ply)
	if (ply._Initialized) then
		if (ply._NextSpawnGender ~= "") then
			ply._Gender = ply._NextSpawnGender ply._NextSpawnGender = ""
			ply._GenderWord = ply._NextSpawnGenderWord ply._NextSpawnGenderWord = ""
		end

		-- Set it so that the ply does not drop weapons.
		ply:ShouldDropWeapon(false)

		-- Check if we're not doing a light spawn.
		if (not ply._LightSpawn) then
			ply:Recapacitate();

			-- Set some of the ply's variables.
			-- ply._Ammo = {}
			ply._Sleeping = false
			ply._Stunned = false
			ply._Tripped = false
			ply._ScaleDamage = 1
			ply._HideHealthEffects = false
			ply._CannotBeWarranted = CurTime() + 15
			ply._Deaded = nil
			SendUserMessage("PlayerSpawned", ply);

			-- Make the ply become conscious again.
			ply:WakeUp(true);
			--ply:UnSpectate()
			-- Set the ply's model and give them their loadout.
			self:PlayerSetModel(ply)
			self:PlayerLoadout(ply)
		end

		-- Call a gamemode hook for when the ply has finished spawning.
		hook.Call("PostPlayerSpawn",GAMEMODE, ply, ply._LightSpawn, ply._ChangeTeam)

		-- Set some of the ply's variables.
		ply._LightSpawn = false
		ply._ChangeTeam = false
	else
		ply:KillSilent()
	end
end

-- Called when a ply should take damage.
function GM:PlayerShouldTakeDamage(ply, attacker) return true end

-- Called when a ply is attacked by a trace.
function GM:PlayerTraceAttack(ply, damageInfo, direction, trace)
	ply._LastHitGroup = trace.HitGroup

	-- Return false so that we don't override internals.
	return false
end

-- Called just before a ply dies.
function GM:DoPlayerDeath(ply, attacker, damageInfo)
	ply._Deaded = true
	if ply:InVehicle() then
		ply:ExitVehicle()
	end
	if (ply:GetNWBool("Typing") and IsValid(attacker) and attacker:IsPlayer()) then
		player.NotifyAll(NOTIFY_CHAT, "%s (%s) killed %s while " .. (ply._GenderWord == "his" and "he" or "she") .. " was typing!", attacker:Name(), attacker:SteamID(), ply:Name());
	end
	if IsValid(ply._BackGun) then
		ply._BackGun:Remove()
	end
	for k, v in pairs( ply:GetWeapons() ) do
		local class = v:GetClass()

		-- Check if this is a valid item.
		if (self.Items[class]) then
			if ( hook.Call("PlayerCanDrop",GAMEMODE, ply, class, true, attacker) ) then
				self.Items[class]:Make(ply:GetPos(), 1);
			end
		end
	end
	-- Do not do this any more.
	--[[
	if #ply._StoredWeapons >= 1 then
		for _, v in pairs(ply._StoredWeapons) do
			local class = v

			-- Check if this is a valid item.
			if (self.Items[class]) then
				if ( hook.Call("PlayerCanDrop",GAMEMODE, ply, class, true, attacker) ) then
					self.Items[class]:Make(ply:GetPos(), 1);
				end
			end
		end
	end
	--]]
	ply._StoredWeapons = {}

	-- Unwarrant them, unarrest them and stop them from bleeding.
	ply:UnWarrant();
	ply:UnArrest(true);
	ply:UnTie(true);
	ply:StopBleeding()

	-- Strip the ply's weapons and ammo.
	ply:StripWeapons()
	ply:StripAmmo()

	-- Add a death to the ply's death count.
	ply:AddDeaths(1)

	-- Check it the attacker is a valid entity and is a ply.
	if ( IsValid(attacker) and attacker:IsPlayer() ) then
		if (ply ~= attacker) then
			if ( hook.Call("PlayerCanGainFrag",GAMEMODE, attacker, ply) ) then
				attacker:AddFrags(1)
			end
		end
	end
end

-- Called when a ply dies.
function GM:PlayerDeath(ply, inflictor, attacker, ragdoll,fall)

	if (ply:KnockedOut()) then
		ply:GetRagdollEntity():SetCollisionGroup(COLLISION_GROUP_WORLD);
	else
		ply:KnockOut();
	end

	-- Set their next spawn time.
	ply.NextSpawnTime = CurTime() + ply._SpawnTime;

	-- Set it so that we can the next spawn time client side.
	umsg.Start("MS Respawn Time", ply);
	umsg.Short(ply._SpawnTime);
	umsg.End();

	-- Check if the attacker is a ply.
	local formattext,text1,text2,text3,pvp = "",ply:GetName(),"",""
	if ( attacker:IsPlayer() ) then
		pvp,text1,text2,formattext = true,attacker:Name(),ply:Name(),"%s killed %s"
		if ( IsValid( attacker:GetActiveWeapon() ) ) then
			formattext,text3 = formattext.." with a %s.",attacker:GetActiveWeapon():GetClass()
		else
			formattext = formattext.."."
		end
	elseif( attacker:IsVehicle() ) then
		local formattext,text1,text2 = "%s was run over by a %s",ply:Name(),attacker:GetClass();
		if attacker.DisplayName then
			text2 = attacker.DisplayName
		elseif attacker.VehicleName then
			text2 = attacker.VehicleName
		end
		if ( IsValid( attacker:GetDriver()) and attacker:GetDriver():IsPlayer()) then
			pvp = true
			formattext,text3 = formattext.." driven by %s",attacker:GetDriver():Name()
		end
	elseif fall then
		formattext = "%s fell to a clumsy death."
	elseif attacker:IsWorld() and ply == inflictor then
		formattext = "%s starved to death."
	elseif attacker:GetClass() == "worldspawn" then
		formattext = "%s was killed by the map."
	elseif attacker:GetClass() == "prop_physics" then
		formattext,text2 = "%s was killed with a physics object. (%s)",attacker:GetModel()
	else
		formattext,text1,text2 = "%s killed %s.",attacker:GetClass(),ply:Name()
	end
	GM:Log(EVENT_DEATH,formattext,text1,text2,text3)
end

local function donttazemebro(class)
	return class:find'cider' or class:find'prop';
end

-- Called when an entity takes damage.
local vector0 = Vector(5,0,0)
function GM:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	--[[
	if !entity or !inflictor or !attacker or entity == NULL or inflictor == NULL or attacker == NULL then
		ErrorNoHalt("Something went wrong in EntityTakeDamage: "..tostring(entity).." "..tostring(inflictor).." "..tostring(attacker).." "..tostring(amount).."\n")
		return
	end
	--]]
	local logme = false
	if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )) then
		if attacker:GetActiveWeapon():GetClass() == "weapon_stunstick" then
			damageInfo:SetDamage(10)
		elseif attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" then
			if entity:IsPlayer() then
				damageInfo:SetDamage(0)
				return false
			else
				damageInfo:SetDamage(10)
			end
		end
	end
	if (attacker:IsPlayer()	and (attacker:GetMoveType()	== MOVETYPE_NOCLIP or attacker._StuckInWorld))
	or (entity:IsPlayer()	and entity:GetMoveType()	== MOVETYPE_NOCLIP and not entity:InVehicle())
	or (entity:IsPlayer()	and entity._Physgunnin) then
		damageInfo:SetDamage(0)
		return false
	end
	local asplode = false
	local asplodeent = nil
	if inflictor:GetClass() == "npc_tripmine" and IsValid(inflictor._planter) then
		damageInfo:SetAttacker(inflictor._planter)
		attacker = inflictor._planter
		asplode = true
		asplodeent = "tripmine"
	elseif attacker:GetClass() == "cider_breach" and IsValid(attacker._Planter) then
		damageInfo:SetAttacker(attacker._Planter)
		attacker = attacker._Planter
		asplode = true
		asplodeent = "breach"
	elseif (inflictor:GetClass() == "cider_hands" and amount == 0) then
		-- Because of the dual damage system, ignore this.
		return;
	end
	if ( entity:IsPlayer() ) then
		if (entity:KnockedOut()) then
			if ( IsValid(entity.ragdoll.entity) ) then
				hook.Call("EntityTakeDamage",GAMEMODE, entity.ragdoll.entity, inflictor, attacker, damageInfo:GetDamage(), damageInfo)
			end
		else
			-- :/ hacky
			if attacker:IsVehicle() and attacker:GetClass() ~= "prop_vehicle_prisoner_pod" then
				entity:KnockOut(10,attacker:GetVelocity());
				damageInfo:SetDamage(0)
				local smitee = entity:GetName()
				local weapon = "."
				local isplayer = false
				local smiter = "an unoccupied "
				if attacker:GetDriver():IsValid() then
					isplayer = true
					smiter = attacker:GetDriver():Name()
					weapon = " in a "
					if attacker.VehicleName then
						weapon = weapon..attacker.VehicleName
					else
						weapon = weapon..attacker:GetClass()
					end
				elseif attacker.VehicleName then
					smiter = smiter..attacker.VehicleName
				else
					smiter = smiter..attacker:GetClass()
				end
				local text = "%s knocked over %s%s"
				if isplayer then
					GM:Log(EVENT_PLAYERDAMAGE,text,smiter,smitee,weapon)
				else
					GM:Log(EVENT_DAMAGE,text,smiter,smitee,weapon)
				end
				return
			end
			if entity:InVehicle() then
				if damageInfo:IsExplosionDamage() and (not damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
					damageInfo:SetDamage(100)
				end
				if damageInfo:GetDamage()< 1 then
					damageInfo:SetDamage(0)
					return
				end
			end
			if attacker:GetClass():find"cider" or self.Config["Anti propkill"] and not damageInfo:IsFallDamage() and attacker:GetClass():find("prop_physics") then
				damageInfo:SetDamage(0)
				return
			end

			-- Check if the player has a last hit group defined.
			if entity._LastHitGroup and ( not attacker:IsPlayer() or (IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() ~= "cider_hands")) then
				if (entity._LastHitGroup == HITGROUP_HEAD) then
					damageInfo:ScaleDamage( self.Config["Scale Head Damage"] )
				elseif (entity._LastHitGroup == HITGROUP_CHEST or entity._LastHitGroup == HITGROUP_GENERIC) then
					damageInfo:ScaleDamage( self.Config["Scale Chest Damage"] )
				elseif (
				entity._LastHitGroup == HITGROUP_LEFTARM or
				entity._LastHitGroup == HITGROUP_RIGHTARM or
				entity._LastHitGroup == HITGROUP_LEFTLEG or
				entity._LastHitGroup == HITGROUP_RIGHTLEG or
				entity._LastHitGroup == HITGROUP_GEAR) then
					damageInfo:ScaleDamage( self.Config["Scale Limb Damage"] )
				end

				-- Set the last hit group to nil so that we don't use it again.
				entity._LastHitGroup = nil
			end

			-- Check if the player is supposed to scale damage.
			if (entity._ScaleDamage) then damageInfo:ScaleDamage(entity._ScaleDamage) end
			logme = true
			if entity:InVehicle() then
				entity:SetHealth(entity:Health()-damageInfo:GetDamage()) --Thanks gayry for breaking teh pains in vehicles.
				damageInfo:SetDamage(0) -- stop the engine doing anything odd
				-- Check to see if the player's health is less than 0 and that the player is alive.
				if ( entity:Health() <= 0 and entity:Alive() ) then
					entity:KillSilent()

					-- Call some gamemode hooks to fake the player's death.
					hook.Call("DoPlayerDeath",GAMEMODE, entity, attacker, damageInfo)
					hook.Call("PlayerDeath",GAMEMODE, entity, inflictor, attacker, damageInfo:IsFallDamage())
				end
			end
			-- Make the player bleed.
			entity:Bleed(self.Config["Bleed Time"])
		end
	elseif ( entity:IsNPC() ) then
		if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
		and attacker:GetActiveWeapon():GetClass() == "weapon_crowbar") then
			damageInfo:SetDamage(25)
		end
		local smiter = attacker:GetClass()
		local damage = damageInfo:GetDamage()
		local smitee = entity:GetClass()
		local weapon = "."
		local text = "%s damaged a %s for %G damage%s"
		if attacker:IsPlayer() then
			smiter = attacker:GetName()
			if IsValid( attacker:GetActiveWeapon() ) then
				weapon = " with a "..attacker:GetActiveWeapon():GetClass()
			end
		end
		GM:Log(EVENT_DAMAGE,text,smiter,smitee,damage,weapon)
	elseif cider.container.isContainer(entity) and entity:Health() > 0 then
		-- Fookin Boogs.		v
		damageInfo:SetDamageForce(vector0)
		local smiter = attacker:GetClass()
		local damage = damageInfo:GetDamage()
		local smitee = cider.container.getName(entity)
		local weapon = "."
		local text = "%s damaged a %s for %G damage%s"
		if attacker:IsPlayer() then
			smiter = attacker:GetName()
			if IsValid( attacker:GetActiveWeapon() ) then
				weapon = " with a "..attacker:GetActiveWeapon():GetClass()
			end
		end
		entity:SetHealth(entity:Health()-damageInfo:GetDamage())
		if entity:Health() <= 0 then
			text = "%s destroyed a %s with %G damage%s"
			entity:SetHealth(0)
			entity:TakeDamage(1)
		end
		GM:Log(EVENT_DAMAGE,text,smiter,smitee,damage,weapon)
	-- Check if the entity is a knocked out player.
	elseif ( IsValid(entity._Player) and not entity._Corpse) then
		local ply = entity._Player
		-- If they were just ragdolled, give them 2 seconds of damage immunity
		if ply.ragdoll.time and ply.ragdoll.time > CurTime() then
			damageInfo:SetDamage(0)
			return false
		end
		-- Set the damage to the amount we're given.
		damageInfo:SetDamage(amount)

		-- Check if the attacker is not a player.
		if ( not attacker:IsPlayer() ) then
			if attacker ==GetWorldEntity() and inflictor == player then --hunger
--				player:SetHealth( math.max(player:Health() - damageInfo:GetDamage()	, 0) )
--				player.ragdoll.health = player:Health()
--				return
			elseif ( attacker == GetWorldEntity() ) then
				if ( ( entity._NextWorldDamage and entity._NextWorldDamage > CurTime() )
				or damageInfo:GetDamage() <= 10 ) then return end

				-- Set the next world damage to be 1 second from now.
				entity._NextWorldDamage = CurTime() + 1
			elseif attacker:GetClass():find"cider" or attacker:GetClass():find("prop") then
				damageInfo:SetDamage(0)
				return
			else
				if (damageInfo:GetDamage() <= 25) then return end
			end
		else
			if not damageInfo:IsBulletDamage() then
				damageInfo:SetDamage(0)
				return false
			end
			damageInfo:ScaleDamage( self.Config["Scale Ragdoll Damage"] )
		end

		-- Check if the player is supposed to scale damage.
		if (entity._Player._ScaleDamage and attacker ~= GetWorldEntity()) then damageInfo:ScaleDamage(entity._Player._ScaleDamage) end

		-- Take the damage from the player's health.
		ply:SetHealth( math.max(ply:Health() - damageInfo:GetDamage(), 0) )

		-- Set the player's conscious health.
		ply.ragdoll.health = ply:Health()

		-- Create new effect data so that we can create a blood impact at the damage position.
		local effectData = EffectData()
			effectData:SetOrigin( damageInfo:GetDamagePosition() )
		util.Effect("BloodImpact", effectData)

		-- Loop from 1 to 4 so that we can draw some blood decals around the ragdoll.
		for i = 1, 2 do
			local trace = {}

			-- Set some settings and information for the trace.
			trace.start = damageInfo:GetDamagePosition()
			trace.endpos = trace.start + (damageInfo:GetDamageForce() + (VectorRand() * 16) * 128)
			trace.filter = entity

			-- Create the trace line from the set information.
			trace = util.TraceLine(trace)

			-- Draw a blood decal at the hit position.
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
		end

		-- Check to see if the player's health is less than 0 and that the player is alive.
		if ( ply:Health() <= 0 and ply:Alive() ) then
			ply:KillSilent()

			-- Call some gamemode hooks to fake the player's death.
			hook.Call("DoPlayerDeath",GAMEMODE, ply, attacker, damageInfo)
			hook.Call("PlayerDeath",GAMEMODE, ply, inflictor, attacker, damageInfo:IsFallDamage())
		end
		entity = ply
		logme = true
	end
	if logme then
		local smiter = attacker:GetClass()
		local damage = damageInfo:GetDamage()
		local smitee = entity:GetName()
		local weapon = "."
		local isplayer = false
		if attacker:IsPlayer() then
			isplayer = true
			smiter = attacker:GetName()
			if asplode then
				weapon = " with a "..asplodeent
			elseif IsValid( attacker:GetActiveWeapon() ) then
				weapon = " with "..attacker:GetActiveWeapon():GetClass()
			end
		elseif attacker:IsVehicle() then
			smiter = "an unoccupied "
			if attacker:GetDriver():IsValid() then
				isplayer = true
				smiter = attacker:GetDriver():Name()
				weapon = " in a "
				if attacker.VehicleName then
					weapon = weapon..attacker.VehicleName
				else
					weapon = weapon..attacker:GetClass()
				end
			elseif attacker.VehicleName then
				smiter = smiter..attacker.VehicleName
			else
				smiter = smiter..attacker:GetClass()
			end
		elseif damageInfo:IsFallDamage() then
			smiter = "The ground"
		elseif attacker:IsWorld() and entity == inflictor then
			smiter = "Hunger"
		elseif smiter == "prop_physics" then
			smiter = "a prop ("..attacker:GetModel()..")"
		end
		local text = "%s damaged %s for %G damage%s"

		if isplayer then
			GM:Log(EVENT_PLAYERDAMAGE,text,smiter,smitee,damage,weapon)
		else
			GM:Log(EVENT_DAMAGE,text,smiter,smitee,damage,weapon)
		end
	end
end
-- Return the damage done by a fall
function GM:GetFallDamage( ply, vel )
	local val = 580  --No idea. This was taken from the C++ source though, aparently
	return (vel-val)*(100/(1024-val))
end

local function dogive(ply, data)
	for ammo, amt in pairs(data.Ammo) do
		ply:GiveAmmo(amt, ammo);
	end
	local item, give
	for _, class in pairs(data.Weapons) do
		item = GM.Items[class];
		give = true;
		if (not item or ply:Blacklisted("cat", item.Category) == 0) then
			ply._SpawnWeapons[class] = true;
			ply:Give(class);
		end
	end
end
-- Called when a player's weapons should be given.
function GM:PlayerLoadout(ply)
	if ( ply:HasAccess("t") ) then ply:Give("gmod_tool") end
	if ( ply:HasAccess("p") ) then ply:Give("weapon_physgun") end

	-- Give the player the camera, the hands and the physics cannon.
	ply:Give("gmod_camera")
	ply:Give("cider_hands")
	ply._SpawnWeapons = {}
	ply._GunCounts = {}
	local data = ply:GetTeam();
	if (not data) then return end
	dogive(ply, data.StartingEquipment);
	dogive(ply, data.Group.StartingEquipment);
	if (data.Gang) then
		dogive(ply, data.Gang.StartingEquipment);
	end
	-- Select the hands by default.
	ply:SelectWeapon("cider_hands")
end

-- Called when the server shuts down or the map changes.
function GM:ShutDown()
	ErrorNoHalt"----------------------\n"
	ErrorNoHalt(os.date().." - Server shutting down\n")
	ErrorNoHalt"----------------------\n"
	for k, v in pairs( player.GetAll() ) do
		v:HolsterAll()
		ply:SaveData(true)
	end
end

-- Called when a player presses F1.
function GM:ShowHelp(ply) umsg.Start("cider_Menu", ply) umsg.End() end

-- Called when a player presses F2.
-- TODO: Rewrite
function GM:ShowTeam(ply)
	local ent = ply:GetEyeTraceNoCursor().Entity
	-- Check if the player is aiming at a ent.
	if not(IsValid(ent)
	   and ent:IsOwnable()
	   and ply:GetPos():Distance( ply:GetEyeTraceNoCursor().HitPos ) <= 128
	 ) then
			return
	end
	if hook.Call("PlayerCanOwnDoor",GAMEMODE,ply,ent) then
		umsg.Start("cider_BuyDoor",ply)
		umsg.End()
		return
	end
	if not hook.Call("PlayerCanViewEnt",GAMEMODE,ply,ent) then
		ply:Notify("You do not have access to that!",1)
		return
	end
	local tab = {
		title = ent:GetPossessiveName() .. " " .. (ent._isDoor and "door" or ent:GetNWString("Name","entity"));
		access = ent._Owner.access;
		owner = ent._Owner.owner;
	};
	if (tab.owner == ply) then
		tab.owned = {
			sellable = (ent._isDoor and not ent._UnSellable) or nil;
			name = gamemode.Call("PlayerCanSetEntName", ply, ent) and ent:GetDisplayName() or nil;
		};
	end
	datastream.StreamToClients(ply, "Access Menu", tab);
end

function GM:ShowSpare1(ply)
-- ):
end

-- For darkRPers
GM.ShowSpare2 = GM.ShowHelp;

-- Called when a ply attempts to spawn a SWEP.
function GM:PlayerSpawnSWEP(ply, class, weapon)
	if ply:IsSuperAdmin() then
		GM:Log(EVENT_SUPEREVENT,"%s spawned a %s",ply:Name(),class)
		return true
	else
		return false
	end
end

-- Called when a player is given a SWEP.
function GM:PlayerGiveSWEP(ply, class, weapon)
	if ply:IsSuperAdmin() then
		GM:Log(EVENT_SUPEREVENT,"%s gave themselves a %s",ply:Name(),class)
		return true
	else
		return false
	end
end

-- Called when attempts to spawn a SENT.
function GM:PlayerSpawnSENT(ply, class)
	if ply:IsSuperAdmin() then
		GM:Log(EVENT_SUPEREVENT,"%s spawned a %s",ply:Name(),class)
		return true
	else
		return false
	end
end



local timenow = CurTime()
timer.Create("Timer Checker.t",1,0,function()
	timenow = CurTime()
end)
hook.Add("Think","Timer Checker.h",function()
	if timenow < CurTime() - 3 then
		GM:Log(EVENT_ERROR,"Timers have stopped running!")
		player.NotifyAll(NOTIFY_ERROR, "Timers have stopped running! Oh shi-")
		hook.Remove("Think","Timer Checker.h")
	end
end)

-- Create a timer to automatically clean up decals.
timer.Create("Cleanup Decals", 60, 0, function()
	if ( GM.Config["Cleanup Decals"] ) then
		for k, v in pairs( player.GetAll() ) do v:ConCommand("r_cleardecals\n") end
	end
end)


-- Create a timer to give players money for their contraband.
timer.Create("Earning", GM.Config["Earning Interval"], 0, function()
	-- FIXME: Christ on a bike this is a shithole redo the entire thing jesus
	local contratypes = {}
	for key in pairs(GM.Config["Contraband"]) do
		contratypes[key] = true
	end
	local cplayers = {}
	local dplayers = {}


	for _, ent in ipairs(ents.GetAll()) do
		if contratypes[ent:GetClass()] then
			local ply = ent:GetPlayer();
			-- Check if the ply is a valid entity,
			if ( IsValid(ply) ) then
				cplayers[ply] = cplayers[ply] or {refill = 0, money = 0}

				-- Decrease the energy of the contraband.
				ent.dt.energy = math.Clamp(ent.dt.energy - 1, 0, 5)

				-- Check the energy of the contraband.
				if (ent.dt.energy == 0) then
					cplayers[ply].refill = cplayers[ply].refill + 1
				else
					cplayers[ply].money = cplayers[ply].money + GM.Config["Contraband"][ ent:GetClass() ].money
				end
			end
		elseif ent:IsDoor() and ent:IsOwned() then
			local o = ent:GetOwner()
			if type(o) == "Player" and IsValid(o) then
				dplayers[o] = dplayers[o] or { 0, {} }
				-- Increase the amount of tax this player must pay.
				dplayers[o][1] = dplayers[o][1] + GM.Config["Door Tax Amount"]
				-- Insert the door into the player's door table.
				table.insert(dplayers[o][2], ent)
			end
		end
	end
	-- Loop through our players list.
	for k, v in pairs(cplayers) do
		if ( IsValid(k) and k:IsPlayer() and hook.Call("PlayerCanEarnContraband",GAMEMODE, k) ) then
			if (v.refill > 0) then
				k:Notify(v.refill.." of your contraband need refilling!", 1)
			end
			if (v.money > 0) then
				k:Notify("You earned $"..v.money.." from contraband.", 0)

				-- Give the player their money.
				k:GiveMoney(v.money)
			end
		end
	end
	for _,ply in ipairs(player.GetAll()) do
		if (ply:Alive() and not ply.cider._Arrested) then
			ply:GiveMoney(ply._Salary)

			-- Print a message to the player letting them know they received their salary.
			ply:Notify("You received $"..ply._Salary.." salary.", 0)
		end
	end
	if ( GM.Config["Door Tax"] ) then
		-- Loop through our players list.
		for k, v in pairs(dplayers) do
			if ( k:CanAfford(v[1] ) ) then
				k:Notify("You have been taxed $"..v[1].." for your doors.", 0)
			else
				k:Notify("You can't pay your taxes. Your doors were removed.", 1)

				-- Loop through the doors.
				for k2, v2 in pairs( v[2] ) do
					if GM.Entities[v2] then
						k:TakeDoor(v2, true)
					else
						v2:RemoveCallOnRemove("refund");
						v2:Remove()
					end
				end
			end

			-- Take the money from the player.
			k:GiveMoney(-v[1] )
		end
	end
	player.SaveAll()
end)
concommand.Add( "wire_keyboard_press", function() end )
-- A console command to tell all players that a player is typing.
concommand.Add("started_typing", function(ply)
	if (ply:IsValid()) then
		ply:SetNWBool("Typing", true);
	end
end);

-- A console command to tell all players that a player has finished typing.
concommand.Add("finished_typing", function(ply)
	if (ply:IsValid()) then
		ply:SetNWBool("Typing", false);
	end
end);

local servertags = GetConVarString("sv_tags")
if servertags == nil then
	servertags = ""
end
for _,tag in ipairs(GM.Config["sv_tags"]) do
	if not string.find(servertags, tag, 1, true) then
		servertags = servertags..","..tag
	end
end
RunConsoleCommand("sv_tags", servertags )
