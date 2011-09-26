--[[
	~ Serverside Player metatable ~
	~ Applejack ~
--]]
require("CSVars");
---
-- The serverside player metatable
-- @name meta
-- @class table
local meta = _R.Player;
if (not meta) then
	error("["..os.date().."] Applejack Serverside Player metatable: No metatable found!");
end

---------------------
-- Prop Protection --
---------------------

---
-- Adds a person to the player's prop protection buddy list
-- @param ply the person to add
function meta:AddPPFriend(ply)
    if (not IsPlayer(ply)) then
        return;
    end
    local uid  = ply:UniqueID();
    local name = ply:Name();
    self._ppFriends[uid] = name;
    umsg.Start("MS PPUpdate", self);
    umsg.Char(1);
    umsg.String(name);
    umsg.Long(uid);
    umsg.End();
end

---
-- Removes a person from the player's prop protection buddy list
-- @param ply The person to remove
function meta:RemovePPFriend(ply)
    if (not IsPlayer(ply)) then
        return;
    end
    local uid =  ply:UniqueID();
    self._ppFriends[uid] = nil;
    umsg.Start("MS PPUpdate", self);
    umsg.Char(2);
    umsg.Long(uid);
    umsg.End();
end

---
-- Wipes a player's prop protection buddy list
function meta:ClearPPFriends()
    self._ppFriends[uid] = {};
    umsg.Start("MS PPUpdate", self);
    umsg.Char(3);
    umsg.End();
end

---
-- Checks to see if a person is on the player's buddy list
-- @param ply The person to check
function meta:IsPPFriendsWith(ply)
    if (not IsPlayer(ply)) then
        return false;
    end
    return self._ppFriends[ply:UniqueID()] ~= nil;
end

if (not meta.oAddCount) then
	meta.oAddCount = meta.AddCount;
end
function meta:AddCount(name, ent)
	ent:SetPPOwner(self);
	return self:oAddCount(name,ent);
end

---
-- Removes an entity from the player's sandbox count and gives it to the world
-- @param name The AddCount name
-- @param ent The entity to remove
function meta:TakeCount(name, ent)
	local tab = SBoxObjects[self:UniqueID()];
	if (not ( tab and tab[name])) then return end
	for k, e in pairs(tab[name]) do
		if (e == ent) then
			table.remove(tab[name], k);
			break;
		end
	end
	self:GetCount(name);
	ent:SetPPOwner(NULL);
    ent:SetPPSpawner(NULL);
end



----------------------------
-- General Player Library --
----------------------------


----------------------------
--  Set / Unset Functions --
----------------------------

---
-- Give a player access to a the flag(s) specified
-- @param flaglist A list of flags with no spaces or delimiters
function meta:GiveAccess(flaglist)
	local flag,access;
	access = self.cider._Access;
	for i = 1, flaglist:len() do
		flag = flaglist:sub(i,i);
		if (not access:find(flag)) then
			access = access .. flag;
		end
	end
	self.cider._Access = access;

end
---
-- Take away away a player's access to the flag(s) specified
-- @param flaglist A list of flags with no spaces or delimiters
function meta:TakeAccess(flaglist)
	local access;
	access = self.cider._Access;
	for i = 1, flaglist:len() do
		access = access:gsub(flaglist:sub(i,i), "");
	end
	self.cider._Access = access;
end


---
-- Blacklist a player from performing a specific activity
-- @param kind What kind of activity. Can be one of "cat","item","cmd" or "team". In order: Item category, specific item, command or specific team/job.
-- @param thing What specific activity. For instance if the kind was 'cmd', the thing could be 'unblacklist'.
-- @param time How long in seconds to blacklist them for.
-- @param reason Why they have been blacklisted.
-- @param blacklister Who blacklisted them. Preferably a string (the name), can also take a player.
function meta:Blacklist(kind, thing, time, reason, blacklister)
	local blacklist;
	if (type(blacklister) == "Player") then
		blacklister = blacklister:Name();
	end
	blacklist = self.cider._Blacklist[kind];
	blacklist = blacklist or {};
	blacklist[thing] = {
		time = os.time() + time * 60,
		reason = reason,
		admin = blacklister
	}
	self.cider._Blacklist[kind] = blacklist;
end	
---
-- Unblacklist a player from a previously existing blacklist.
-- @param kind What kind of activity. Can be one of "cat","item","cmd" or "team". In order: Item category, specific item, command or specific team/job.
-- @param thing What specific activity. For instance if the kind was 'cmd', the thing could be 'unblacklist'.
function meta:UnBlacklist(kind, thing)
	local blacklist;
	blacklist = self.cider._Blacklist[kind];
	if (blacklist) then
		blacklist[thing] = nil;
		if (table.Count(blacklist) == 0) then
			blacklist = nil;
		end
		self.cider._Blacklist[kind] = blacklist;
	end
end

---
-- Gives a player access to a door, unlocks it, sets the door's name and specifies if the player can sell it.
-- @param door The door entity to be given access to
-- @param name The name to give the door (optional)
-- @param unsellable If the player should be prevented from selling this door.
function meta:GiveDoor(door, name, unsellable)
	if (not (door:IsDoor() and door:IsOwnable())) then
		return;
	end
	door._Unsellable = unsellable;
	door:GiveToPlayer(self);
	if (name and name ~= "") then
		door:SetDisplayName(name);
	end
	door:UnLock();
	door:EmitSound("doors/door_latch3.wav");
	self:AddCount("doors",door)
end

---
-- Removes a player's access to a door, unlocks it and optionally gives them a refund
-- @param door The door to take the access from
-- @param norefund If true, do not give the player a refund
function meta:TakeDoor(door, norefund)
	if (not door:IsDoor() or door:GetOwner() ~= self) then
		return;
	end
	-- Unlock the door so that people can use it again and play the door latch sound.
	door:UnLock()
	door:EmitSound("doors/door_latch3.wav");
	-- Remove our access to it
	door:TakeAccessFromPlayer(self);
	self:TakeCount("doors", door)
	-- Give the player a refund for the door if we're not forcing it to be taken.
	if (not norefund) then
		self:GiveMoney(GM.Config["Door Cost"] / 2);
	end
end

local function jobtimer(ply)
	if (not IsValid(ply)) then return end
	ply:Notify("You have reached the timelimit for this job!", 1);
	ply:Demote();
end
local function TeamChange(ply, id)
	-- Tell the client they can't join this team again.
	umsg.Start("TeamChange", ply);
	umsg.Char(id);
	umsg.End();
end
---
-- Makes the player join a specific team with associated actions
-- @param tojoin What team to join
-- @return success or failure, failure message.
function meta:JoinTeam(tojoin)
	tojoin = team.Get(tojoin);
	if (not tojoin) then
		return false, "That is not a valid team!";
	elseif (self:Blacklisted("team",tojoin.TeamID) > 0) then
		self:BlacklistAlert("team", tojoin.TeamID, tojoin.name);
		return false;
	end
	local oldteam = self:GetTeam();
	-- Ensure they're coming from a team that exists in the gamemode.
	if (oldteam) then
		-- Prevent stored starting weapons being given to people who don't deserve them.
		for _, class in pairs(oldteam.StartingEquipment.Weapons) do
			self._StoredWeapons[class] = nil;
		end
		-- Prevent weapons holstering twice
		timer.Violate(self:UniqueID().." holster");
		-- Prevent hopping back and forth
		self._NextChangeTeam[oldteam.TeamID] = CurTime() + oldteam.Cooldown;
		-- Spam about it
		GM:Log(EVENT_TEAM, "%s changed team from %q to %q.", self:Name(), oldteam.Name, tojoin.Name);
		-- Tell the client they can't join this team again.
		timer.Simple(0, TeamChange, self, oldteam.TeamID);
	else
		GM:Log(EVENT_TEAM, "%s changed team to %q", self:Name(), tojoin.Name);
	end
	self:SetTeam(tojoin.TeamID);
	self._Job = tojoin.Name;
	self:SetNWString("Job", self._Job);
	if ((self._JobTimeExpire or 0) > CurTime()) then
		self._JobTimeExpire = 0;
		self._JobTimeLimit = 0;
		timer.Stop("Job Timelimit: "..self:UniqueID());
	end if (tojoin.TimeLimit ~= 0) then
		self._JobTimeExpire = tojoin.TimeLimit + CurTime();
		self._JobTimeLimit = tojoin.TimeLimit;
		timer.Create("Job Timelimit: "..self:UniqueID(), self._JobTimeLimit, 1, jobtimer, self);
	end
	-- Change our salary.
	self._Salary = tojoin.Salary;
	gamemode.Call("PlayerAdjustSalary", self);

	
	-- Some tidying up
	-- Unwarrant the player.
	self:UnWarrant();
	-- Call the hook to tell various things we've changed team
	gamemode.Call("PlayerChangedTeams", self, oldteam, tojoin.TeamID);
	-- Silently kill the player.
	self._ChangeTeam = oldteam;
	self:KillSilent();
	-- Return true because it was successful.
	return true;
end
umsg.PoolString("TeamChange");

---
-- Demotes a player from their current team.
function meta:Demote()
	self:HolsterAll();
	local data = self:GetTeam();
	local base = data.Group.BaseTeam
	if (base == data) then
		self:JoinTeam(TEAM_DEFAULT)
	else
		self:JoinTeam(base)
	end
end

local function warranttimer(ply)
	if (ply:IsValid()) then
		gamemode.Call("PlayerWarrantExpired", ply, ply:GetNWString("Warrant"));
		ply:UnWarrant();
	end
end

---
-- Applies a warrant to a player.
-- @param class The warrant type to apply. 'arrest' or 'search'.
-- @param time Optional, specify the time for the warrant to last
function meta:Warrant(class, time)
	gamemode.Call("PlayerWarranted", self, class, time);
	self._Warranted = class;
	self:SetNWString("Warrant", class);
	local expires = time or (class == "arrest" and GM.Config["Arrest Warrant Expire Time"] or GM.Config["Search Warrant Expire Time"]);
	-- Prevents any unplesant bugs due to user error.
	if expires <= 0 then
		expires = 0.1
	end
	self:SetCSVar(CLASS_LONG, "_WarrantExpireTime", CurTime() + expires);
	timer.Create("Warrant Expire: "..self:UniqueID(), expires, 1, warranttimer, self, class);
end

---
-- Removes the player's warrant
function meta:UnWarrant()
	gamemode.Call("PlayerUnwarranted", self);
	self._Warranted = nil;
	self:SetNWString("Warrant", "");
	timer.Stop("Warrant Expire: "..self:UniqueID());
end

local uptr,downtr = Vector(0,0,256), Vector(0,0,-1024);
local function dobleed(ply)
	if (not IsValid(ply)) then return end
	local pos = ply:GetPos();
	local tr = util.TraceLine({
		start = pos + uptr,
		endpos = pos + downtr,
		filter = ply,
	});
	util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal);
end
 	
---
-- Causes the player to leave a trail of blood behind them
-- @param time How many seconds they should bleed for. 0 or nil for infinite bleeding.
function meta:Bleed(time)
	timer.Start("Bleeding: "..self:UniqueID(), 0.25, (seconds or 0) * 4, dobleed, self);
end

---
-- Stops the player bleeding immediately.
function meta:StopBleeding()
	timer.Stop("Bleeding: "..self:UniqueID());
end

local function doforce(ragdoll, velocity)
	if (IsValid(ragdoll) and IsValid(ragdoll:GetPhysicsObject())) then
		ragdoll:GetPhysicsObject():SetVelocity(velocity);
	end
end
local function recoveryTimer(ply)
	if (IsValid(ply) and ply:Alive() and ply:KnockedOut()) then
		SendUserMessage("MS Wakeup Call", ply, false);
	end
end
---
-- Knocks out (ragdolls) a player requiring their input to get back up again
-- @param time How long to force them down for. Nil or 0 allows them up instantly.
-- @param velocity What velocity to give to the ragdoll on spawning
function meta:KnockOut(time, velocity)
	if (self:KnockedOut()) then return end -- Don't knock us out if we're out already
	if (self:InVehicle()) then -- This shit goes crazy if you ragdoll in a car. Do not do it.
		self:ExitVehicle();
	end
	-- Grab the player's current bone matrix so the ragdoll spawns as a natural continuation
	local bones,ragdoll, model, angles;
	bones = {};
	for i = 0, 70 do
		bones[i] = self:GetBoneMatrix(i);
	end
	model = self:GetModel();
	if (util.IsValidRagdoll(model)) then
		ragdoll = ents.Create("prop_ragdoll");
	else
		ragdoll = ents.Create("prop_physics");
	end
	if (not IsValid(ragdoll)) then
		error("Invalid ragdoll entity!");
	end
	-- Set preliminary data
	ragdoll:SetModel(model);
	ragdoll:SetPos(self:GetPos());
	angles = self:GetAngles();
	angles.p = 0;
	ragdoll:SetAngles(angles);
	ragdoll:Spawn();
	
	-- Gief to world to prevent people picking it up and waving it about
    ragdoll:SetPPOwner(NULL);
	-- Pose the ragdoll in the same shape as us
	for i, matrix in pairs(bones) do
		ragdoll:SetBoneMatrix(i, matrix);
	end
	-- Try to send it flying in the same direction as us.
	timer.Create("Ragdoll Force Application "..self:UniqueID(), 0.05, 5, doforce, ragdoll, (velocity or self:GetVelocity()) * 2);
	
	-- Make it look even more like us.
	ragdoll:SetSkin		(self:GetSkin()		);
	ragdoll:SetColor	(self:GetColor()	);
	ragdoll:SetMaterial	(self:GetMaterial()	);
	if (self:IsOnFire()) then
		ragdoll:Ignite(16, 0);
	end

	-- Allow other parts of the script to associate it with us.
	ragdoll:SetNWEntity ("Player", self		);
	ragdoll._Player = self;

	-- Allow other parts of the script to associate us with it
	self.ragdoll = {
		entity	= ragdoll;
		health	= self:Health();
		model	= self:GetModel();
		skin	= self:GetSkin();
		team	= self:Team();
	};

	-- We've got some stuff to perform if this isn't a corpse.
	if (self:Alive()) then
		-- Take the player's weapons away for later returnage
		self:TakeWeapons();
		-- If we're being forced down for a while, tell the client.
		if (time and time > 0) then
			time = math.min(time, 32767);
			self._KnockoutPeriod = CurTime() + time;
			umsg.Start("MS Recovery Time", self)
			umsg.Short(time);
			umsg.End();
			timer.Simple(time, recoveryTimer, self);
		end
        -- Stops the ragdoll colliding with players, to prevent accidental/intentional stupid deaths.
        ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    else
        -- Stops the ragdoll colliding with anything, to prevent ragdoll spazzing after a stupid death.
        ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
	-- Get us ready for spectation
	self:StripWeapons();
	self:Flashlight(false);
	self:CrosshairDisable();
	self:StopBleeding();
	
	-- Spectate!
	self:SpectateEntity(ragdoll);
	self:Spectate(OBS_MODE_CHASE);
	
	-- Set some infos for everyone else
	self:SetNWBool("KnockedOut", true);
	self:SetNWEntity("Ragdoll", ragdoll);
	gamemode.Call("PlayerKnockedOut", self);
end

---
-- Wakes a player up (unragdolls them) immediately
-- @param reset If set, do not give the player back the things they had when they were knocked out.
function meta:WakeUp(reset)
	if (not self.ragdoll) then return end
	-- If the player is on a different team to the one they were on when they were knocked out, respawn them. TODO: Why do this?
	if (self:Team() ~= self.ragdoll.team) then
		self.ragdoll.team = self:Team();
		self:Spawn();
		return;
	end
	-- Get us out of this spectation
	self:UnSpectate();
	self:CrosshairEnable();
	-- If we're not doing a reset, then there are things we need to do like giving the player stuff back
	if (not reset) then
		-- Do a light spawn so basic variables are set up
		self:LightSpawn();
		-- Get our weapons back
		self:ReturnWeapons();
		-- Set the basic info we stored
		self:SetHealth(self.ragdoll.health);
		-- Duplicate the ragdoll's current state if it exists
		local ragdoll = self:GetRagdollEntity();
		if (IsValid(ragdoll)) then
			self:SetPos(ragdoll:GetPos());
			self:SetModel(ragdoll:GetModel());
			self:SetSkin(ragdoll:GetSkin());
			self:SetColor(ragdoll:GetColor());
			self:SetMaterial(ragdoll:GetMaterial());
		else -- Otherwise set the state we were in to start with
			self:SetModel(self.ragdoll.model);
			self:SetSkin(self.ragdoll.skin);
		end
	end
	-- If the ragdoll exists, remove it.
	if (IsValid(self:GetRagdollEntity())) then
		self:GetRagdollEntity():Remove();
	end
	-- Wipe the ragdoll table
	self.ragdoll = {};
	-- Reset the various knockout state vars
	self._Stunned = false;
	self._Tripped = false;
	self._Sleeping= false;
	
	-- Set some infos for everyone else
	self:SetNWBool("KnockedOut", false);
	self:SetNWEntity("Ragdoll", ragdoll);
	gamemode.Call("PlayerWokenUp", self);
end

---
-- Takes a player's weapons away and stores them in a table for later returnal
-- @param noitems Do not save any items the player has equipped
function meta:TakeWeapons(noitems)
	local class;
	for _, weapon in pairs(self:GetWeapons()) do
		class = weapon:GetClass();
		if (not (noitems and GM.Items[class])) then
			self._StoredWeapons[class] = true;
		end
	end
	if (IsValid(self:GetActiveWeapon())) then
		self._StoredWeapon = self:GetActiveWeapon():GetClass();
	else
		self._StoredWeapon = nil;
	end
	self:StripWeapons();
end

---
-- Gives a player their stored weapons back
function meta:ReturnWeapons()
	if (not gamemode.Call("PlayerCanRecieveWeapons", self)) then
		return false;
	end
	for class in pairs(self._StoredWeapons) do
		self:Give(class);
		self._StoredWeapons[class] = nil;
	end
	if (self._StoredWeapon) then
		self:SelectWeapon(self._StoredWeapon);
		self._StoredWeapon = nil;
	else
		self:SelectWeapon("cider_hands");
	end
end

---
-- incapacitates a player - drops their movement speed, prevents them from jumping or doing most things.
function meta:Incapacitate()
	self:SetRunSpeed( GM.Config["Incapacitated Speed"]);
	self:SetWalkSpeed(GM.Config["Incapacitated Speed"]);
	self:SetJumpPower(0);
	self:SetNWBool("Incapacitated", true);
end

---
-- Recapacitates a player, letting them walk, run and jump like normal
function meta:Recapacitate()
	if (not gamemode.Call("PlayerCanBeRecapacitated", self)) then
		return false;
	end
	self:SetRunSpeed( GM.Config["Run Speed" ]);
	self:SetWalkSpeed(GM.Config["Walk Speed"]);
	self:SetJumpPower(GM.Config["Jump Power"]);
	self:SetNWBool   ("Incapacitated",  false);
	return true;
end	

---
-- Ties a player up so they cannot do anything but walk about
function meta:TieUp ()
	if (self:Tied()) then return end
	self:Incapacitate();
	self:TakeWeapons();
	self:SetNWBool("Tied", true);
	self:Flashlight(false);
end

---
-- Unties a player so that they can do things again
-- @param reset If true, do not give the player their weapons back
function meta:UnTie(reset)
	if (not reset and not self:Tied()) then return end
	self:SetNWBool("Tied", false);
	if (not reset) then
		self:Recapacitate();
		self:ReturnWeapons();
	end
end

local function arresttimer(ply)
	if (not IsValid(ply)) then return end
	ply:UnArrest(true);
	ply:Notify("Your arrest time has finished!");
	ply:Spawn(); -- Let the player out of jail
end
---
-- Arrest a player so they cannot do most things, then unarrest them a bit later
-- @param time Optional - Specify how many seconds the player should be arrested for. Will default to the player's ._ArrestTime var
function meta:Arrest(time)
	if (self:Arrested()) then return end
	gamemode.Call("PlayerArrested", self);
	self.cider._Arrested = true;
	self:SetNWBool("Arrested", true);
	timer.Create("UnArrest: "..self:UniqueID(), time or self._ArrestTime, 1, arresttimer, self);
	self:SetCSVar(CLASS_LONG, "_UnarrestTime", CurTime() + (time or self._ArrestTime));
	self:Incapacitate();
	self:TakeWeapons(true);
	self:StripAmmo();
	self:Flashlight(false);
	self:UnWarrant();
	self:UnTie(true);
end
---
-- Unarrest an arrested player before their timer has run out.
function meta:UnArrest(reset)
	if (not self:Arrested()) then return end
	gamemode.Call("PlayerUnArrested", self);
	self.cider._Arrested = false;
	self:SetNWBool("Arrested", false);
	self:SetCSVar(CLASS_LONG, "_UnarrestTime", 0);
	timer.Stop("UnArrest: "..self:UniqueID());
	if (not reset) then
		self:Recapacitate();
		self:ReturnWeapons();
	end
end

-- Handles known keys
local function handleKnownKey(ply, k, v)
	local a = player.loadKnownKeys[k];
	if (a == "function") then
		player.loadFunctions[k](ply, v);
	elseif (a == "number") then
		ply.cider[k] = tonumber(v) or 0;
	elseif (a == "GLON") then
		local s,r = pcall(glon.decode, v);
		if not s then
			ErrorNoHalt("["..os.date().."] Error decoding "..ply:Name().."'s '"..k.."' table with string '"..tostring(v):sub(1,20).."...'. GLON Returned '"..r.."'\n");
		else
			ply.cider[k] = r or {};
		end
	elseif (a == "bool") then
		ply.cider[k] = tobool(v);
	else
		ply.cider[k] = tostring(v);
	end
end

-- Called if a player has saved data
local function loadCallback(ply, data)
	for k,v in pairs(data) do
		if (player.loadIgnoreKeys[k]) then
		elseif (player.loadKnownKeys[k]) then
			handleKnownKey(ply, k, v);
		else
			if (tonumber(v)) then
				ply.cider[k] = tonumber(v);
			elseif (v:sub(1,1):byte() == 2) then
				local a,b = pcall(glon.decode, v);
				if not a then
					ErrorNoHalt("["..os.date().."] Error decoding "..ply:Name().."'s '"..k.."' table with string '"..tostring(v):sub(1,20).."...'. GLON Returned '"..b.."'\n");
				else
					ply.cider[k] = b or {};
				end
			elseif (v == "true" or v == "false") then
				ply.cider[k] = tobool(v);
			else
				ply.cider[k] = tostring(v);
			end
		end
	end
	GM:Log(EVENT_DEBUG,"Loading of %s's data complete.",ply:Name())
	gamemode.Call("PlayerDataLoaded", ply, true);
end

-- Recursive load timer
local function timerfunc(ply)
	if (IsValid(ply) and not ply._Initialized) then
		ply:LoadData();
	end
end
---
-- Load a player's data from the SQL database, overwriting any data already loaded on the player. Performs it's actions in a threaded query.
-- If the player's data has not been loaded after 30 seconds, it will call itself again
function meta:LoadData()
	local ply = self; -- Keywords do not work well as upvalues.
	local name = ply:Name(); -- In case they leave and then cause an error.
	-- Set up the default cider table. 
	ply.cider = {
		_Name = ply:Name(),
		_Misc = {},
		_Clan = GM.Config["Default Clan"],
		_Money = GM.Config["Default Money"],
		_Access = "", -- No one needs the default access any more, as hasAccess catches it. GM.Config["Default Access"],
		_Donator = 0,
		_SteamID = ply:SteamID();
		_UniqueID = ply:UniqueID();
		_Arrested = false,
		_Inventory = {},
		_Blacklist = {},
	}
	tmysql.query("SELECT * FROM " .. GM.Config["MySQL Table"] .. " WHERE _UniqueID = " .. self:UniqueID(), function(r, s, e)
		if (e ~= 0) then
			GM:Log(EVENT_ERROR,"SQL Error loading %q's data: %s", name, tostring(e));
		elseif (not IsValid(ply)) then
			return
		elseif (type(r) == "table" and #r > 0) then -- If we've got a result, then call the loadfunc
			loadCallback(ply, r[1]);
		else -- Otherwise we gotta init the player as new.
			ply.cider._Inventory = table.Copy(GM.Config["Default Inventory"]); -- Give the player some items!
			GM:Log(EVENT_DEBUG, "%s is new to the server. Data not loaded.", ply:Name())
			gamemode.Call("PlayerDataLoaded", ply, false);
			ply:SaveData(true);
		end
	end, 1);
	-- Try loading again in 30 seconds if the loading hasn't worked by then.
	timer.Simple(30, timerfunc, self);
end

-- Returns the SQL ready keys and values from the player's .cider table in two tables
local function getKVs(ply)
	local keys, values = {}, {};
	local value;
	for k,v in pairs(ply.cider) do
		value = nil;
		if (player.saveIgnoreKeys[k]) then
			value = false;
		elseif (player.saveFunctions[k]) then
			value = player.saveFunctions[k](ply, v);
		elseif (type(v) == "table") then
			local s, r = pcall(glon.encode, v);
			if (not s) then
				ErrorNoHalt("["..os.date().."] Error encoding "..ply:Name().."'s '"..k.."' table: "..r.."\n");
			else
				value = r;
			end
		elseif (player.saveEscapeKeys[k]) then
			value = tmysql.escape(tostring(v));
		else
			value = tostring(v);
		end
		if (value) then
			table.insert(keys, k);
			table.insert(values, value);
		end
	end
	return keys, values;
end

-- Creates a CREATE query to make a new entry in the SQL DB and returns it
local function createCreateQuery(ply)
	local keys,values = getKVs(ply);
	local query = "INSERT INTO "..GM.Config["MySQL Table"].." (";
	for _, key in pairs(keys) do
		query = query .. key .. ", ";
	end
	query = query:sub(1, -3) .. ") VALUES (";
	for _, value in pairs(values) do
		query = query .. '"' .. value .. '", ';
	end
	return query:sub(1, -3) .. ")";
end

-- Creates an UPDATE query and returns it
local function createUpdateQuery(ply)
	local keys,values = getKVs(ply);
	local query = "UPDATE "..GM.Config["MySQL Table"].." SET ";
	for i = 1, #keys do
		query = query .. keys[i] .. ' = "' .. values[i] .. '", ';
	end
	return query:sub(1, -3) .. " WHERE _UniqueID = "..ply:UniqueID();
end

---
-- Save a player's data to the SQL server in a threaded query.
-- @param create Whether to create a new entry or do a normal update.
function meta:SaveData(create)
	if (not self._Initialized) then return end
    gamemode.Call("PlayerSaveData", self);
	local query = create and createCreateQuery(self) or createUpdateQuery(self);
	local name = self:Name(); -- In case they leave and then cause an error.
	tmysql.query(query, function(r, s, e)
		if (e ~= 0) then
			GM:Log(EVENT_ERROR,"SQL Error in %q's save: %s", name, tostring(e));
		else
			GM:Log(EVENT_SQLDEBUG,"SQL Statement successful for %q", name);
		end
	end);
end

----------------------------
--     Get Functions      --
----------------------------

---
-- Check if a player has access to the flag(s) specified.
-- @param flaglist A list of flags with no spaces or delimiters
-- @param any Whether to search for any flag on the list (return true at the first flag found), or for every flag on the list. (return false on the first flag not found)
-- @return true on succes, false on failure.
function meta:HasAccess(flaglist, any)
	local access, teamaccess, flag;
	access = self.cider._Access;
	for i = 1, flaglist:len() do
		flag = flaglist:sub(i,i);
		if(flag == GM.Config["Default Access"]
		or GM.FlagFunctions[flag] and GM.FlagFunctions[flag](self)
		or access:find(flag)) then
			if (any) then return true; end -- If 'any' is selected, then return true whenever we get a match
		elseif (not any) then -- If 'any' is not selected we don't get a match, return false.
			return false;
		end
	end
	-- If 'any' is selected and none have matched, return false. If 'any' is not selected and we have matched every flag return true.
	return not any;
end

---
-- Checks if a player is blacklisted from using something
-- and also returns the reason and blacklister if they are.
-- @param kind What kind of activity. Can be one of "cat","item","cmd" or "team". In order: Item category, specific item, command or specific team/job.
-- @param thing What specific activity. For instance if the kind was 'cmd', the thing could be 'unblacklist'.
-- @return 0 if the player is not blacklisted, otherwise the time in seconds, the reason and the name of the blacklister.
function meta:Blacklisted(kind, thing)
	local blacklist,time;
	blacklist = self.cider._Blacklist[kind];
	if (not (blacklist and blacklist[thing])) then
		return 0;
	end
	blacklist = blacklist[thing];
	time = blacklist.time - os.time();
	if (time <= 0) then
		self:UnBlacklist(kind, thing);
		return 0;
	end
	return time / 60, blacklist.reason, blacklist.admin;
end

---
-- Convienence function: Checks if a player has more (or equal) money than the amount specified.
-- @param amount The amount of money to compare the player's against
-- @return True if they have enough, false and the amount needed if not.
function meta:CanAfford(amount)
	local money = self:GetMoney();
	if (money < amount) then
		return false, amount - money;
	else
		return true, money - amount;
	end
end

---
-- Gets a player's money
-- @return How much money the player currently has
function meta:GetMoney()
	return self.cider._Money;
end

---
-- Checks if a player is able to pick up an entity based on various limits.
-- This is a Lua version of CBasePlayer::CanPickupObject kindly ported by blackops7799 and then tweaked by me.
-- You can find the original at http://goo.gl/FEFFE
-- @param pObject The entity you wish to pick up
-- @param massLimit The maximum mass the entity may possess.
-- @param sizeLimit The maximum size the entity may be in the X, Y or Z planes. (Diagonal lengths ignored)
-- @return True if they can pick it up, false if they can't.
function meta:CanPickupObject( pObject, massLimit, sizeLimit )
    if (pObject == NULL) then
        return false, "Object is NULL";
    elseif (pObject:GetMoveType() ~= MOVETYPE_VPHYSICS) then
        return false, "Object cannot be moved!";
    elseif (self:GetGroundEntity() == pObject) then
        return false, "You're standing on that!";
    end

    if (not massLimit) then
        massLimit = 35;
    end
    if (not sizeLimit) then
        sizeLimit = 128;
    end
     
    local count = pObject:GetPhysicsObjectCount();
     
    if (not count) then
        return false, "This object has no physics!";
    end
     
    local objectMass = 0;
    local checkEnable = false;
         
    for i = 0, count - 1 do
        local pList = pObject:GetPhysicsObjectNum(i);
        objectMass = objectMass + pList:GetMass();
        if (pList:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)) then
            return false, "The map maker has asked that you not be able to pick this up.";
        --[[elseif ( pList:IsHinged() ) then -- Not possible now
            return false;]]
        elseif (not pList:IsMoveable()) then
            checkEnable = true;
        end
    end
     
    if (massLimit > 0 and objectMass > massLimit) then
        return false, "That object is too heavy!";
    elseif (checkEnable and not pObject:HasSpawnFlags(64)) then
        return false, "That object is stuck!";
    end
     
    if (sizeLimit > 0) then       
        local maxs = pObject:OBBMaxs();
        local mins = pObject:OBBMins();
        local sizez = maxs.z - mins.z;
        local sizey = maxs.y - mins.y;
        local sizex = maxs.x - mins.x;
        if (sizex > sizeLimit or sizey > sizeLimit or sizez > sizeLimit) then
            return false, "That object is too big for you to move!";
        end
    end
    return true;
end

----------------------------
--    Action Functions    --
----------------------------

---
-- Sends a generic radio message to everyone in the player's team or gang.
-- Also emits a normal speach version of the message.
-- Note: Calls "PlayerAdjustRadioRecipients" to allow plugins to change who hears the message
-- TODO: Remove this and set up a frequency based thingy.
-- @param words The words the player should send in the radio message
function meta:SayRadio(words)
	local recipients;
	local data = self:GetTeam();
	if (data.Gang) then
		recipients = GM:GetGangMembers(data.Gang);
	else
		recipients = team.GetPlayers(data.TeamID);
	end
	
	-- Call a hook to allow plugins to adjust who also gets the message.
	gamemode.Call("PlayerAdjustRadioRecipients", self, words, recipients);
	
	-- Compile a list of those who can't hear the voice
	local nohear = {}
	-- Loop through every recipient and add the message to their chatbox
	for _,ply in pairs(recipients) do
		cider.chatBox.add(ply, self, "radio", words);
		nohear[ply] = true;
	end
	
	-- Tell everyone nearby that we just said a waydio
	local pos = self:GetPos();
	for _,ply in pairs(player.GetAll()) do
		if (not nohear[ply] and ply:GetPos():Distance(pos) <= GM.Config["Talk Radius"]) then
			cider.chatBox.add(ply, self, "loudradio", words);
		end
	end
end

---
-- Adds an emote to the chatbox coming from the player
-- @param words What the emote should say
function meta:Emote(words)
	cider.chatBox.addInRadius(self, "me", words, self:GetPos(), GM.Config["Talk Radius"]);
end

---
-- Adds an amount of money to the player's money count and triggers an alert on the client.
-- @param amount How much money to add (can be negative)
function meta:GiveMoney(amount)
	self.cider._Money = math.max(self.cider._Money + amount, 0);
	SendUserMessage("MoneyAlert", self, amount);
end
umsg.PoolString("MoneyAlert");

---
-- Causes a player to put all their weapons into their inventory instantly. If a weapon will not fit, it is dropped at their feet to reduce loss.
function meta:HolsterAll()
	if (self:InVehicle()) then
		self:ExitVehicle(); -- This fixes a suprisingly high number of glitches
	end
	local class;
	for _, weapon in pairs(self:GetWeapons()) do
		class = weapon:GetClass();
		if (GM.Items[class]) then
			if (gamemode.Call("PlayerCanHolster", self, class, true) and cider.inventory.update(self, class, 1)) then
				self:StripWeapon(class);
			elseif (gamemode.Call("PlayerCanDrop", self, class, true)) then
				GM.Items[class]:Make(self:GetPos(), 1);
			end
		end
	end
	self:SelectWeapon("cider_hands");
end

---
-- Notify a player of something, generally using Garry's notifications system.
-- @param message The message to display
-- @param level The notification level. Nil or unspecified = chat message. 0 = Water drip. 1 = Failure buzzer. 2 = 'Bip' Notification. 3 = 'Tic' Notification. (Used by the cleanup)
function meta:Notify(message, level)
	if (level == nil) then
		cider.chatBox.add(self, nil, "notify", message);
		return;
	end
	umsg.Start("Notification", self);
		umsg.String(message);
		umsg.Char(level);
	umsg.End();
end

---
-- Lightly spawn a player (Do not reset any important vars)
function meta:LightSpawn()
	self._LightSpawn = true;
	self:Spawn();
end


local angle_zero = Angle(0,0,0);
---
-- Sets a variable clientside on the player. Will not send the same value twice.
-- @param class One of the CLASS_ enums indicating the kind of variable
-- @param key The name of the variable to set on the client
-- @param value The value to set
function meta:SetCSVar(class, key, value)
	CSVars.SetPlayer(self, class, key, value)
end

---
-- Notifies the player that they've been blacklisted from using something
-- @param kind What kind of activity. Can be one of "cat","item","cmd" or "team". In order: Item category, specific item, command or specific team/job.
-- @param thing What specific activity. For instance if the kind was 'cmd', the thing could be 'unblacklist'.
-- @param name The name of what it is
function meta:BlacklistAlert(kind, thing, name)
	local time, reason, admin = self:Blacklisted(kind, thing);
	if (time >= 1440) then
		time = math.ceil(time / 1440) .. " days";
	elseif (time >= 60) then
		time = math.ceil(time / 60) .. " hours";
	else 
		time = time .. " minutes";
	end
	self:Notify("You have been blacklisted from using " .. tostring(name) .. " by " .. admin .. " for " .. time .. " for '" .. reason .. "'!");
end
