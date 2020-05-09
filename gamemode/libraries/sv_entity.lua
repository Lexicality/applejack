--
-- ~ Serverside Entity Library ~
-- ~ Applejack ~
--
---
-- A table of all currently ownable entities, with the entity as a key
GM.OwnableEntities = {};

local function unbreach(ent)
	if (not IsValid(ent)) then
		return
	end
	ent._Jammed = nil;
	ent:UnLock(0, true);
	local close = ent._Autoclose or GM.Config["Door Autoclose Time"];
	local class = ent:GetClass();
	if (class:find "func_door") then
		ent:SetKeyValue("wait", close);
	elseif (class:find "prop_door") then
		ent:SetKeyValue("returndelay", close);
	end
	GM:CloseDoor(ent, 0);
end

---
-- Opens a door
-- @param ent The door in question
-- @param delay How many seconds to wait before doing it
-- @param unlock Whether to unlock the door before opening it
-- @param jam If the door should jam open (Doesn't always work)
function GM:OpenDoor(ent, delay, unlock, jam)
	if (not IsValid(ent)) then
		error("NULL entity passed to OpenDoor!", 2);
	elseif (not (ent:IsDoor() and ent:IsOwnable())) then
		error("Non-door passed to OpenDoor!", 2);
	elseif (delay and delay > 0) then
		return
			timer.Simple(delay, self.OpenDoor, self, ent, false, unlock, sound, jam);
	elseif (ent._Jammed or ent._Sealed or ent._DoorState == "open") then
		return false;
	end
	delay = 0;
	if (unlock) then
		ent:UnLock();
		delay = 0.025;
	end
	if (ent:GetClass() == "prop_dynamic") then
		ent:Fire("setanimation", "open", delay);
		ent._DoorState = "open";
		ent._Autoclose = ent._Autoclose or GM.Config["Door Autoclose Time"];
	else
		ent:Fire("open", "", delay);
	end
	if (jam) then
		ent._Jammed = true;
		ent:Lock(delay + 0.025, true);
		local class = ent:GetClass();
		if (class:find "func_door") then
			ent:SetKeyValue("wait", GM.Config["Jam Time"]);
		elseif (class:find "prop_door") then
			ent:SetKeyValue("returndelay", GM.Config["Jam Time"]);
		end
		timer.Simple(GM.Config["Jam Time"], unbreach, ent);
	elseif (ent._Autoclose or 0 > 0) then
		self:CloseDoor(ent, ent._Autoclose);
	end
end

---
-- Close a door
-- @param ent The door in question
-- @param delay How many seconds to wait before doing it
-- @param lock Whether to lock the door after closing it
function GM:CloseDoor(ent, delay, lock)
	if (not IsValid(ent)) then
		error("NULL entity passed to CloseDoor!", 2);
	elseif (not (ent:IsDoor() and ent:IsOwnable())) then
		error("Non-door passed to CloseDoor!", 2);
	elseif (delay and delay > 0) then
		return timer.Simple(delay, self.CloseDoor, self, ent, false, lock);
	elseif (ent._Jammed or ent._Sealed or ent._DoorState == "closed") then
		return false;
	elseif (ent:GetClass() == "prop_dynamic") then
		ent:Fire("setanimation", "close", 0);
		ent._DoorState = "closed";
	else
		ent:Fire("close", "", 0);
	end
	if (lock) then
		ent:Lock(0.025);
	end
end

local saves = {};
---
-- Save the access data for every ent the player owns and deown them - use when a player disconnects.
-- @param ply The player in question
function GM:SaveAccess(ply)
	local id = ply:UniqueID();
	saves[id] = saves[id] or {};
	local tab = saves[id];
	for ent in pairs(self.OwnableEntities) do
		if (IsValid(ent) and ent:IsOwnable()) then
			if (ent._Owner.owner == ply) then
				ent = ent:GetMaster() or ent;
				tab[ent] = {};
				for access in pairs(ent._Owner.access) do
					if (type(access) == "Player" and IsValid(access)) then
						tab[ent][access:UniqueID()] = true;
					else
						tab[ent][access] = true;
					end
				end
				tab[ent]._name = ent:GetDisplayName()
				ent:ClearOwnershipData();
			elseif (ent._Owner.access[ply]) then
				ent._Owner.access[ply] = nil;
				ent._Owner.access[ply:UniqueID()] = true;
			end
		else
			self.OwnableEntities[ent] = nil;
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
---
-- Restore a stored player's access, if the entities have not been reclaimed since they were stored.
-- DOES NOT TELL THE PLAYER THEY HAVE ACCESS. This is supposed to be run just before a team change, when they would be informed of all their entities, and so does not duplicate functionality.
-- @param ply The player in question
function GM:RestoreAccess(ply)
	local id, pl = ply:UniqueID();
	if (not saves[id]) then
		return;
	end
	local filter = RecipientFilter();
	for ent, access in pairs(saves[id]) do
		if (IsValid(ent) and not ent:IsOwned()) then
			filter:RemoveAllPlayers();
			for data in pairs(access) do
				if (data ~= "_name") then
					pl = player.UniqueIDs[data];
					ent._Owner.access[pl or data] = true;
					if (pl) then
						filter:AddPlayer(pl);
					end
				end
			end
			ent._Owner.owner = ply;
			ent:SetDisplayName(access._name);
			acc(ent, filter, true);
		end
	end
	saves[id] = nil;
	for ent in pairs(self.OwnableEntities) do
		if (IsValid(ent) and ent:IsOwnable()) then
			if (ent._Owner.access[id]) then
				ent._Owner.access[id] = nil;
				ent._Owner.access[ply] = true;
			end
		end
	end
end

timer.Create(
	"Applejack Entity Housecleaning", GM.Config["Earning Interval"], 0, function()
		for ent in pairs(GM.OwnableEntities) do
			if (not IsValid(ent)) then
				GM.OwnableEntities[ent] = nil;
			end
		end
	end
)
