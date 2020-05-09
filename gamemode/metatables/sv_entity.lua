--
-- ~ Serverside Entity metatable ~
-- ~ Applejack ~
--
local meta = _R.Entity;
if (not meta) then
	error(
		"[" .. os.date() ..
			"] Applejack Serverside Entity metatable: No metatable found!"
	);
end

-- Locals

-- This makes sure an entity is actually ownable before running stuff on it.
local function cm(ent)
	if (not ent._Owner) then
		error("Tried to use a nonownable entity!", 3);
	end
end

-- Gets all the players from a stringid
local function getplys(data)
	local kind, id = string.match(data, "(%a+): (.+)");
	if (kind == "Group") then
		return GM:GetGroupMembers(id);
	elseif (kind == "Gang") then
		return GM:GetGangMembers(id);
	elseif (kind == "Team") then
		return team.GetPlayers(id);
	end
	return {};
end

-- Gets the relevent object from a stringid
local function getobj(data)
	local kind, id = string.match(data, "(%a+): (.+)");
	if (kind == "Group") then
		return GM:GetGroup(id);
	elseif (kind == "Gang") then
		return GM:GetGang(id);
	elseif (kind == "Team") then
		return team.Get(id);
	end
end

-- Updates the name normal and NWVar
local function setname(ent, name)
	ent._Owner.name = name;
	ent:SetNWString("DisplayName", name);
end

-- Updates the owner + name
local function newowner(ent, owner, name, slave)
	ent._Owner.owner = owner;
	setname(ent, name)
	if (not slave) then
		for slave in pairs(ent._Owner.slaves) do
			if (IsValid(slave)) then
				newowner(slave, owner, name, true);
			end
		end
	end
end

local function acc(ent, fil, sta)
	for ent in pairs(ent._Owner.slaves) do
		acc(ent, fil, sta);
	end
	umsg.Start("AccessChange", fil);
	umsg.Short(ent:EntIndex());
	umsg.Bool(sta);
	umsg.End();
end

-- Notify multiple players that their access has been changed
local function multiaccesschange(ent, plys, stat)
	if (not IsValid(ent)) then
		return
	end
	cm(ent);
	if (#plys == 0) then
		return;
	end
	local filter = RecipientFilter();
	for _, ply in pairs(plys) do
		if (IsValid(ply)) then
			filter:AddPlayer(ply);
		end
	end
	acc(ent, filter, stat);
end

-- Notify a player that their access has been changed
local function accesschange(ent, ply, stat)
	if (not IsValid(ent)) then
		return
	end
	cm(ent);
	acc(ent, ply, stat);
end

-- 'Is'/'Has' functions

---
-- Checks to see if the entity is considered a door by the script.
-- @return True if it is, false if it isn't.
function meta:IsDoor()
	local class, model = self:GetClass(), self:GetModel();
	return self._isDoor or class == "func_door" or class == "func_door_rotating" or
       		class == "prop_door_rotating" or class == "prop_dynamic" and
       		(model:find("door") or model:find("gate")) and
       		(self:LookupSequence("open") or 0) > 0 and
       		(self:LookupSequence("close") or 0) > 0;
end

---
-- Checks to see if an entity is ownable.
-- @return True if it is, false if it isn't.
function meta:IsOwnable()
	return self._Owner and true or false;
end

---
-- Checks to see if an entity is owned.
-- @return True if it is, false if it isn't.
function meta:IsOwned()
	return self._Owner and self._Owner.owner ~= NULL or false;
end

---
-- Checks to see if a player has access to the entity
-- @return True if they do, false if they don't.
function meta:HasAccess(ply)
	if (not self._Owner) then
		return false;
	end
	if (not IsValid(ply)) then
		error("bad argument #1 to 'HasAccess' (Player expected, got NULL)", 2);
	end
	local data = team.Get(ply:Team());
	local access, owner = self._Owner.access, self._Owner.owner;
	if (owner == ply or access[ply]) then
		return true;
	elseif (not data) then
		return false;
	end
	local tid, gid, ggid = "Team: " .. data.TeamID,
                       	"Group: " .. data.Group.GroupID,
                       	"Gang: " .. (data.Gang and data.Gang.GangID or -1);
	return (owner == tid or owner == gid or owner == ggid) or
       		(access[tid] or access[gid] or access[ggid]);
end

-- 'Set'/'Get' functions

---
-- Gets all players that have some kind of access to the entity
-- @return A table of players in no particular order
function meta:GetAllAccessors()
	cm(self);
	if (not self:IsOwned()) then
		return {};
	end
	local ret, working, kind = {};
	working = table.Copy(self._Owner.access);
	working[self._Owner.owner] = true;
	for data in pairs(working) do
		kind = type(data);
		if (kind == "Player") then
			ret[#ret + 1] = data;
		elseif (kind == "string") then
			table.Add(ret, getplys(data));
		end
	end
	working = {};
	for _, ply in pairs(ret) do
		working[ply] = true;
	end
	ret = {};
	for ply in pairs(working) do
		if (IsValid(ply)) then
			ret[#ret + 1] = ply;
		end
	end
	return ret;
end

---
-- Sets the displayed owner's name for the ent
-- @param name The name to set
function meta:SetDisplayName(name)
	cm(self);
	if (not self:IsOwned()) then
		error("This function cannot be run on unowned entities.", 2);
	end
	setname(self, name);
end

---
-- Gets the displayed owner's name
-- @return The name or "" if the entity if not owned. (Note: The name may have been set to "".)
function meta:GetDisplayName()
	return self:GetNWString("DisplayName");
end

---
-- Gets the 'possessive' name of an entity. ie John's, The Police's or The Doctors'
-- @return The name.
function meta:GetPossessiveName()
	cm(self);
	local name = "Nobody";
	local owner = self._Owner.owner;
	if (owner ~= NULL) then
		if (type(owner) == "Player") then
			name = owner:Name();
		elseif (type(owner) == "string") then
			local data = getobj(owner);
			if (data) then
				name = data.PossessiveString and
       					string.format(data.PossessiveString, data.Name) or data.Name;
			end
		end
	end
	return name .. "'s";
end

---
-- Gets a string appropriate to describe this entity as a door.
-- @return A string describing the door
function meta:GetDoorName()
	if (not self:IsDoor()) then
		error("Tried to use on a non-door!", 2);
	end
	local name = self:GetNWString("Name");
	local dispname = "";
	if (self:IsOwned()) then
		dispname = self:GetDisplayName();
	end
	if (name ~= "") then
		if (dispname ~= "") then
			return name .. " - " .. dispname;
		end
		return name;
	end
	return dispname;
end

meta.OriginalGetOwner = meta.GetOwner;
---
-- Gets the owner of an entity.
-- NOTE: The existing :GetOwner() function will be called if the entity isn't ownable. If you want to call that function on an entity you made ownable, use :OriginalGetOwner().
-- @return The Owner, the player object if it's a player or the table if it's a team/gang/group
function meta:GetOwner()
	if (not self._Owner) then
		return self:OriginalGetOwner();
	end
	local owner = self._Owner.owner;
	if (owner == NULL) then
		return nil;
	elseif (type(owner) == "Player") then
		return owner;
	end
	return getobj(owner);
end

---
-- Sets the 'master' of an entity.
-- Slave enties share the same access data as their master (but not necessarily the same display names)
-- @param ent The entity to slave to. Pass NULL to deslave this entity.
function meta:SetMaster(ent)
	-- DEVELOPER NOTE: The .access table is shared between master and slave, while the .owner field isn't.
	-- Remember that any changes to .access will be changed on all, but any changes to .owner won't.
	cm(self);
	local data = self._Owner
	if (not IsValid(ent)) then
		ent = self:GetMaster()
		if (not ent) then
			return;
		end
		ent._Owner.slaves[self] = nil;
		data.master = NULL;
		data.access = {};
		self:ClearOwnershipData();
		return;
	elseif (not ent:IsOwnable()) then
		error(

			
				"bad argument #1 to 'SetMaster' (Ownable Entity expected, got something else)",
				2
		);
	end
	ent = ent:GetMaster() or ent;
	if (ent == self or self:GetMaster() == ent) then
		return;
	end
	for slave in pairs(data.slaves) do
		if (IsValid(slave)) then
			slave:SetMaster(ent);
		end
		data.slaves[slave] = nil;
	end
	multiaccesschange(self, self:GetAllAccessors(), false);
	data.access = ent._Owner.access;
	data.owner = ent._Owner.owner;
	data.master = ent;
	setname(self, ent._Owner.name);
	multiaccesschange(self, self:GetAllAccessors(), true);
end

---
-- Gets the master of an entity
-- @return The master entity, or nil if it is not valid.
function meta:GetMaster()
	cm(self);
	local master = self._Owner.master;
	return IsValid(master) and master or nil;
end

---
-- Gets an entities slaves
-- @return A numerically indexed table of entities
function meta:GetSlaves()
	cm(self);
	local tab = {};
	for slave in pairs(self._Owner.slaves) do
		if (IsValid(slave)) then
			tab[#tab + 1] = slave;
		else
			self._Owner.slaves[slave] = nil;
		end
	end
	return tab;
end

-- Action functions

---
-- Locks an ownable entity
-- @param delay Pauses for this many seconds before locking
-- @param force Forces the lock, even if the entity is jammed
function meta:Lock(delay, force, done)
	cm(self);
	if (delay) then
		return timer.Simple(delay, self.Lock, self, false, force);
	end
	if (self._Locked == true or (self._Jammed and not force)) then
		return false;
	end
	if (self._isDoor or self._isVehicle) then
		self:Fire("lock");
	end
	self._Locked = true;
	self:SetDTInt(3, bit.bor(self:GetDTInt(3), OBJ_LOCKED));
	for _, ent in pairs(self._Owner.lockbuddies) do
		ent:Lock(0, force);
	end
end

---
-- Unlocks an ownable entity
-- @param delay Pauses for this many seconds before unlocking
-- @param force Forces the unlock, even if the entity is jammed
function meta:UnLock(delay, force)
	cm(self);
	if (delay) then
		return timer.Simple(delay, self.UnLock, self, false, force);
	end
	if (self._Locked == false or (self._Jammed and not force)) then
		return false;
	end
	if (self._isDoor or self._isVehicle) then
		self:Fire("unlock");
	end
	self._Locked = false;
	self:SetDTInt(3, bit.band(self:GetDTInt(3), bit.bnot(OBJ_LOCKED)));
	for _, ent in pairs(self._Owner.lockbuddies) do
		ent:UnLock(0, force);
	end
end

---
-- Seals an entity so it cannot be opened/closed/locked/unlocked
function meta:Seal()
	cm(self);
	self._Sealed = true;
	self:SetDTInt(3, bit.bor(self:GetDTInt(3), OBJ_SEALED));
end

---
-- Unseals a previously sealed entity
function meta:UnSeal()
	cm(self);
	self._Sealed = false;
	self:SetDTInt(3, bit.band(self:GetDTInt(3), bit.bnot(OBJ_SEALED)));
end

---
-- Makes an entity ownable so it can be owned by players / teams
function meta:MakeOwnable()
	if (self:IsPlayer() or self:IsOwnable()) then
		return;
	end
	self._Owner = {
		name = "Nobody",
		access = {},
		owner = NULL,
		slaves = {},
		master = NULL,
		lockbuddies = {},
	};
	if (self:IsDoor()) then
		self._isDoor = true;
		self._eName = "door";
	elseif (self:IsVehicle()) then
		self._isVehicle = true;
		self._eName = "vehicle";
	end
	self:UnLock();
	GM.OwnableEntities[self] = true;
	self:SetNWString("DisplayName", "Nobody");
	self:SetDTInt(3, bit.bor(self:GetDTInt(3), OBJ_OWNABLE));
end

---
-- Clears all ownership related data on an entity and informs bereaved accessors.
function meta:ClearOwnershipData()
	cm(self);
	multiaccesschange(self, self:GetAllAccessors(), false);
	for data in pairs(self._Owner.access) do
		self._Owner.access[data] = nil;
	end
	newowner(self, NULL, "Nobody");
end

-- Access functions

-- Tells the current owner that they are no longer the owner.
local function deown(self)
	local owner = self._Owner.owner;
	if (not owner or owner == NULL) then
		return;
	end
	local kind = type(owner);
	if (kind == "Player") then
		accesschange(self, owner, false);
	elseif (kind == "String") then
		multiaccesschange(self, getplys(owner), false);
	end
end

--
-- Players
--

---
-- Gives a player basic access to the entity
-- @param ply The player to do it to
function meta:GiveAccessToPlayer(ply)
	cm(self);
	if (not IsValid(ply)) then
		error("bad argument #1 to 'GiveAccessToPlayer' (Player expected, got NULL)", 2);
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access[ply] = true;
	accesschange(self, ply, true);
end

---
-- Takes away a player's access from an entity
-- @param ply The player to do it to
function meta:TakeAccessFromPlayer(ply)
	cm(self)
	if (not IsValid(ply)) then
		error(
			"bad argument #1 to 'TakeAccessFromPlayer' (Player expected, got NULL)", 2
		);
	end
	if (self._Owner.owner == ply) then
		self = self:GetMaster() or self;
		return self:ClearOwnershipData();
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access[ply] = nil;
	if (not self:HasAccess(ply)) then
		accesschange(self, ply, false);
	end
end

---
-- Give a player owner access to an entity
-- @param ply The player to do it to
function meta:GiveToPlayer(ply)
	cm(self);
	if (not IsValid(ply)) then
		error("bad argument #1 to 'GiveToPlayer' (Player expected, got NULL)", 2);
	end
	self = self:GetMaster() or self;
	deown(self);
	newowner(self, ply, ply:Name());
	accesschange(self, ply, true);
end

meta.TakeFromPlayer = meta.TakeAccessFromPlayer;

--
-- Teams
--

---
-- Gives every player on a team basic access to the entity while they're on that team
-- @param id The id of the team in question
function meta:GiveAccessToTeam(id)
	cm(self);
	local data = team.Get(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'GiveAccessToTeam' (TeamID expected, got something else)",
				2
		);
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access["Team: " .. data.TeamID] = true;
	multiaccesschange(self, team.GetPlayers(data.TeamID), true);
end

---
-- Takes away a team's access from an entity. (If an individual has access through any other route, they retain it.)
-- @param id The id of the team in question
function meta:TakeAccessFromTeam(id)
	cm(self);
	local data = team.Get(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'TakeAccessFromTeam' (TeamID expected, got something else)",
				2
		);
	end
	id = "Team: " .. data.TeamID;
	if (self._Owner.owner == id) then
		self = self:GetMaster() or self;
		return self:ClearOwnershipData();
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access[id] = nil;
	local bereft = {};
	for _, ply in pairs(team.GetPlayers(data.TeamID)) do
		if (not self:HasAccess(ply)) then
			bereft[#bereft + 1] = ply;
		end
	end
	if (#bereft > 0) then
		multiaccesschange(self, bereft, false);
	end
end

---
-- Give a team owner access to an entity. Gameplay wise, it acts as if they only had basic access.
-- @param id The id of the team in question
function meta:GiveToTeam(id)
	cm(self);
	local data = team.Get(id);
	if (not data) then
		error(
			"bad argument #1 to 'GiveToTeam' (TeamID expected, got something else)", 2
		);
	end
	self = self:GetMaster() or self;
	deown(self);
	newowner(self, "Team: " .. data.TeamID, data.Name);
	multiaccesschange(self, team.GetPlayers(data.TeamID), true);
end

meta.TakeFromTeam = meta.TakeAccessFromTeam;

--
-- Gangs
--

---
-- Gives every player on a gang basic access to the entity while they're in that gang
-- @param id The id of the gang in question
function meta:GiveAccessToGang(id)
	cm(self);
	local data = GM:GetGang(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'GiveAccessToGang' (GangID expected, got something else)",
				2
		);
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access["Gang: " .. data.GangID] = true;
	multiaccesschange(self, GM:GetGangMembers(data.GangID), true);
end

---
-- Takes away a gang's access from an entity. (If an individual has access through any other route, they retain it.)
-- @param id The id of the gang in question
function meta:TakeAccessFromGang(id)
	cm(self);
	local data = GM:GetGang(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'TakeAccessFromGang' (GangID expected, got something else)",
				2
		);
	end
	id = "Gang: " .. data.GangID;
	if (self._Owner.owner == id) then
		self = self:GetMaster() or self;
		return self:ClearOwnershipData();
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access[id] = nil;
	local bereft = {};
	for _, ply in pairs(GM:GetGangMembers(data.GangID)) do
		if (not self:HasAccess(ply)) then
			bereft[#bereft + 1] = ply;
		end
	end
	if (#bereft > 0) then
		multiaccesschange(self, bereft, false);
	end
end

---
-- Give a gang owner access to an entity. Gameplay wise, it acts as if they only had basic access.
-- @param id The id of the gang in question
function meta:GiveToGang(id)
	cm(self);
	local data = GM:GetGang(id);
	if (not data) then
		error(
			"bad argument #1 to 'GiveToGang' (GangID expected, got something else)", 2
		);
	end
	self = self:GetMaster() or self;
	deown(self);
	newowner(self, "Gang: " .. data.GangID, data.Name);
	multiaccesschange(self, GM:GetGangMembers(data.GangID), true);
end

meta.TakeFromGang = meta.TakeAccessFromGang;

--
-- Groups
--

---
-- Gives every player on a group basic access to the entity while they're in that group
-- @param id The id of the group in question
function meta:GiveAccessToGroup(id)
	cm(self);
	local data = GM:GetGroup(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'GiveAccessToGroup' (GroupID expected, got something else)",
				2
		);
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access["Group: " .. data.GroupID] = true;
	multiaccesschange(self, GM:GetGroupMembers(data.GroupID), true);
end

---
-- Takes away a group's access from an entity. (If an individual has access through any other route, they retain it.)
-- @param id The id of the group in question
function meta:TakeAccessFromGroup(id)
	cm(self);
	local data = GM:GetGroup(id);
	if (not data) then
		error(

			
				"bad argument #1 to 'TakeAccessFromGroup' (GroupID expected, got something else)",
				2
		);
	end
	id = "Group: " .. data.GroupID;
	if (self._Owner.owner == id) then
		self = self:GetMaster() or self;
		return self:ClearOwnershipData();
	end
	if (not self:IsOwned()) then
		return;
	end
	self._Owner.access[id] = nil;
	local bereft = {};
	for _, ply in pairs(GM:GetGroupMembers(data.GroupID)) do
		if (not self:HasAccess(ply)) then
			bereft[#bereft + 1] = ply;
		end
	end
	if (#bereft > 0) then
		multiaccesschange(self, bereft, false);
	end
end

---
-- Give a group owner access to an entity. Gameplay wise, it acts as if they only had basic access.
-- @param id The id of the group in question
function meta:GiveToGroup(id)
	cm(self);
	local data = GM:GetGroup(id);
	if (not data) then
		error(
			"bad argument #1 to 'GiveToGroup' (GroupID expected, got something else)", 2
		);
	end
	self = self:GetMaster() or self;
	deown(self);
	newowner(self, "Group: " .. data.GroupID, data.Name);
	multiaccesschange(self, GM:GetGroupMembers(data.GroupID), true);
end

meta.TakeFromGroup = meta.TakeAccessFromGroup;

---------------------
-- Prop Protection --
---------------------

-- Setting --

---
-- Sets the prop protection (nothing to do with the ownership system) owner of an entity
-- @param target Who should now own the entity. If this is not a player, the entity is given to The World.
function meta:SetPPOwner(target)
	self._pp = self._pp or {};
	if (IsPlayer(target)) then
		self._pp.Owner = target;
		self._pp.OwnerUID = target:UniqueID();
		self._pp.OwnerName = target:Name();
	else
		self._pp.Owner = game.GetWorld();
		self._pp.OwnerUID = "WORLD";
		self._pp.OwnerName = "The World";
	end
end

---
-- Sets who the prop protection system believes spawned the entity.
-- @param target Who should now have spawned the entity. If this is not a player, it defaults to The World
function meta:SetPPSpawner(target)
	self._pp = self._pp or {};
	if (IsPlayer(target)) then
		self._pp.Spawner = target;
		self._pp.SpawnerName = target:Name();
	else
		self._pp.Spawner = game.GetWorld();
		self._pp.SpawnerName = "The World";
	end
end

-- Getting --

---
-- Gets the prop protection owner of an entity.
-- @return The owner's entity, the owner's name and then the owner's UniqueID
function meta:GetPPOwner()
	if (not self._pp) then
		return nil;
	end
	return self._pp.Owner, self._pp.OwnerName, self._pp.OwnerUID;
end

---
-- Gets who the prop protection system thinks spawned the entity
-- @return The spawner's entity followed by their name.
function meta:GetPPSpawner()
	if (not self._pp) then
		return nil;
	end
	return self._pp.Spawner, self._pp.SpawnerName;
end
