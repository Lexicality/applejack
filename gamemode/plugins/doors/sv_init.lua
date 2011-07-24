--[[
	~ Doors Plugin / SV ~
	~ Applejack ~
--]]

--[[
Changelog:
29/1/10: Mostly rewritten to use the new plugin format and be sane.
04/06/11: Completely rewritten to use v113 game.CleanupMap compatible shizzle + team lib
]]

PLUGIN.Name = "Doors";
PLUGIN.Doors = {};

function PLUGIN:LoadDoors()
	self.Doors = {};
	local path = GM.LuaFolder .. "/doors/" .. string.lower(game.GetMap()) .. ".txt";
	if (not file.Exists(path)) then
		error("Can't find the path '" .. path .. "'!");
		return;
	end
	local stat, res = pcall(glon.decode, file.Read(path));
	if (not stat) then
		error("["..os.date().."] Doors Plugin: Error GLON decoding '"..path.."': "..res);
	elseif (not results) then
		return;
	end
	local ent, ment;
	for id, data in pairs(res) do
		ent = ents.GetMapCreatedEntity(id);
		if (not IsValid(ent)) then
			ErrorNoHalt("[",os.date(),"] Doors Plugin: No such entity '", id, "' as specified for map ", game.GetMap(), " in the stored data!");
			continue;
		end
		if (data.Master) then
			ment = ents.GetMapCreatedEntity(data.Master);
			if (IsValid(ment)) then
				ent:SetMaster(ment);
			end
		end
		if (data.Sealed) then
			ent:Seal();
		end
		if (data.Owner) then
			local kind, id = string.match(data.Owner, "(.+): (.+)");
			if (not (kind and id)) then
				ErrorNoHalt("[",os.date(),"] Doors Plugin: Malformed owner field for ", id, ": ", data.Owner); 
				continue;
			end
			local func = GM["Get" .. kind];
			if (not func) then
				ErrorNoHalt("[",os.date(),"] Doors Plugin: Malformed owner field for ", id, ": ", data.Owner); 
				continue;
			end
			local owner = func(GM, id);
			if (not owner) then
				ErrorNoHalt("[",os.date(),"] Doors Plugin: Unknown owner for ", id, ": ", data.Owner);
				continue;
			end
			ent["GiveTo" .. kind](ent, owner);
		end
		if (data.Name) then
			entity:SetNWSTring("Name", data.Name);
		end
		if (data.Unownable) then
			if (not data.Owner) then
				ent:GiveToTeam(TEAM_NOBODY);
			end
			ent:SetDisplayName(data.Unownable);
			ent._Unownable = true;
		end
		self.Doors[ent] = data;
	end
end


-- Called when all good plugins should load their datas. (Normally a frame after InitPostEntity)
function PLUGIN:LoadData()
	self:LoadDoors();
end

-- Called when a player attempts to jam a door (ie with a breach)
function PLUGIN:PlayerCanJamDoor(ply, door)
	if (door._Unownable) then
		return false
	end
end

--Called when a player attempts to own a door.
function PLUGIN:PlayerCanOwnDoor(player, door)
	if (door._Unownable) then
		return false;
	end
end

-- Gets the data for the door, either creating it if it doesn't exist or returning a blank table.
function PLUGIN:GetDoorData(door, create)
	local ret;
	if (self.Doors[door]) then
		ret = self.Doors[door];
	elseif (create) then
		ret = {
			Position = door._StartPos or door:GetPos();
		}
		self.Doors[door] = ret;
	else
		ret = {};
	end
	return ret;
end

local function care(door)
	return IsValid(door) and door:CreatedByMap() and door:IsDoor() and door:IsOwnable();
end

-- Called when data needs to be saved
function PLUGIN:SaveData()
	local ret = {};
	local stat = 0;
	local res;
	for ent, data in pairs(self.Doors) do
		if (care(ent)) then
			stat = stat + 1;
			res = data;
			if (res.Owner) then
				res.Owner = res.Owner.Type .. ": " .. res.Owner.UniqueID;
			end
			if (res.Master and care(res.Master)) then
				res.Master = res.Master:MapCreationID();
			end
			ret[ent:MapCreationID()] = res;
		end
	end
	if (stat == 0) then return; end
	stat, res = pcall(glon.encode, ret);
	if (not stat) then
		error("["..os.date().."] Doors Plugin: Error GLON encoding "..game.GetMap().."'s door data: "..res);
	end
	file.Write(GM.LuaFolder .. "/doors/" .. string.lower(game.GetMap()) .. ".txt", res);
end

function PLUGIN:EntityNameSet(door, name)
	if (not care(door)) then
		return
	elseif (not name or name == "") then
		self:GetDoorData(door).Name = nil;
	else
		self:GetDoorData(door,true).Name = name;
	end
	self:SaveData();
end

function PLUGIN:EntityMasterSet(door,master)
	if (not care(door)) then
		return
	elseif (IsValid(master)) then
		self:GetDoorData(door,true).Master = master;
	else
		self:GetDoorData(door).Master = nil;
	end
	self:SaveData();
end

function PLUGIN:EntitySealed(door,unsealed)
	if (not care(door)) then
		return
	elseif (unsealed) then
		self:GetDoorData(door).Sealed = nil;
	else
		self:GetDoorData(door,true).Sealed = true;
	end
	self:SaveData();
end

function PLUGIN:EntityOwnerSet(ent, owner)
	if (not care(door)) then
		return;
	end
	if (not owner) then
		self:GetDoorData(door).Owner = nil;
	else
		self:GetDoorData(ent, true).Owner = owner;
	end	if (data.Unownable) then
		ent:SetDisplayName(data.Unownable);
	end
	self:SaveData();
end

local plugin = PLUGIN;
cider.command.add("unownable", "s", 0, function(ply, action, ...)
	local door = ply:GetEyeTraceNoCursor().Entity;
	if (not (IsValid(door) and door:IsOwnable() and door:IsDoor())) then
		return false, "You must look at a valid door!";
	end
	door = door:GetMaster() or door;
	if (action == "remove") then
		if (not door._Unownable) then
			return false, "That door is not currently set as unownable!";
		end
		door._Unownable = nil;
		door:ClearOwnershipData();
		local data = plugin:GetDoorData(door);
		if (data.Owner) then -- Is this door pre-owned by a team or gang?
			door["GiveTo" .. data.Owner.Type](door, data.Owner);
		end
		local name = door:GetDoorName()
		ply:Notify("'"..name.."' is no longer unownable.");
		GM:Log(EVENT_EVENT,"%s de unownable'd %q",ply:Name(),name)
	else
		local name = (action or "").." "..table.concat({...}, " ");
		name:Trim();
		local data = plugin:GetDoorData(door, true);
		data.Unownable = name;
		door._Unownable = true;
		if (not data.Owner) then
			door:ClearOwnershipData();
			door:GiveToTeam(TEAM_NOBODY);
		elseif (data.Owner ~= door:GetOwner()) then -- Does someone who shouldn't own this?
			door["GiveTo" .. data.Owner.Type](door, data.Owner);
		end
		door:SetDisplayName(name)
		name = door:GetDoorName()
		ply:Notify("'"..name.."' is now unownable.");
		GM:Log(EVENT_EVENT,"%s unownable'd %q",ply:Name(),name)
	end
	plugin:SaveData();
end, "Super Admin Commands", "<name|remove>", "Add (and optionally name) or remove an unownable door.", true);
