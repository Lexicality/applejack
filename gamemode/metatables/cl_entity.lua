--
-- ~ Clientside Entity metatable ~
-- ~ Applejack ~
--
local meta = _R.Entity;
if (not meta) then
	error("["..os.date().."] Applejack Clientside Entity metatable: No metatable found!");
end

-- 'Is' functions

---
-- Checks to see if the entity is considered a door by the script.
-- @return True if it is, false if it isn't.
function meta:IsDoor()
	local class, model = self:GetClass(), self:GetModel();
	return self._isDoor or class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
		or class == "prop_dynamic" and (model:find("door") or model:find("gate")) and (self:LookupSequence("open") or 0) > 0 and (self:LookupSequence("close") or 0) > 0;
end

---
-- Checks to see if an entity is ownable.
-- @return True if it is, false if it isn't.
function meta:IsOwnable()
	return bit.band(self:GetDTInt(3), OBJ_OWNABLE) == OBJ_OWNABLE;
end

---
-- Checks to see if an entity is owned.
-- @return True if it is, false if it isn't.
function meta:IsOwned()
	return self:GetNWString("DisplayName","Nobody") ~= "Nobody";
end

---
-- Checks to see if the player has access to the entity
-- @return True if they do, false if they don't.
function meta:HasAccess()
	return self._HasAccess;
end

---
-- Checks to see if an entity is locked.
-- @return True if it is, false if it isn't.
function meta:Locked()
	return bit.band(self:GetDTInt(3), OBJ_LOCKED) == OBJ_LOCKED;
end

-- 'Get' functions


---
-- Gets the displayed owner's name
-- @return The name or "" if the entity if not owned. (Note: The name may have been set to "".)
function meta:GetDisplayName()
	return self:GetNWString("DisplayName");
end

local poetic = CreateClientConVar("cider_poetic", 1, true);
function meta:GetStatus()
	local status = ""
	local p = poetic:GetBool()
	if (self._HasAccess) then
		if p then
			status = "You have access to this"
		else
			status = "(Access)"
		end
	end
	local dt = self:GetDTInt(3);
	-- if bit.band(dt), OBJ_INUSE) == OBJ_INUSE then
	-- 	if p then
	-- 		if status == "" then
	-- 			status = "This is in use"
	-- 		else
	-- 			status = status.. ", but it is in use"
	-- 		end
	-- 	else
	-- 		status = status.."(In Use)"
	-- 	end
	-- end
	-- if bit.band(dt, OBJ_RAMMABLE) == OBJ_RAMMABLE then
	-- 	if p then
	-- 		if status == "" then
	-- 			status = "You may ram this"
	-- 		else
	-- 			status = status..". You may ram it"
	-- 		end
	-- 	else
	-- 		status = status.."(Rammable)"
	-- 	end
	-- end
	if bit.band(dt, OBJ_LOCKED) == OBJ_LOCKED then
		if p then
			if status == "" then
				status = "This is locked"
			else
				status = status.." and it is locked"
			end
		else
			status = status.."(Locked)"
		end
	end
	if bit.band(dt, OBJ_SEALED) == OBJ_SEALED then
		if p then
			if status == "" then
				status = "This is sealed shut"
			elseif status:sub(-2,-1) == "ed" then
				status = status.." and sealed shut"
			else
				status = status..". It is sealed shut"
			end
		else
			status = status.."(Sealed)"
		end
	end
	if status ~= "" and p then
		status = status.."."
	end
	return status
end

function meta:DefaultESPPaint(lines, pos, dist, center)
	if (self:GetClass() == "prop_ragdoll") then
		local ply = self:GetNWEntity("Player");
		if (not ply:IsValid() or ply == lpl) then
			return;
		end
		return ply:ESPPaint(lines, pos, dist, center, true);
	elseif (not self:IsOwnable()) then
		return;
	end
	local name = "";
	if (self:IsDoor()) then
		if (not center) then
			lines:Kill();
			return;
		end
		name = self:GetNWString("Name", "Door");
		local owner = self:GetDisplayName()
		if (owner == "Nobody") then -- Door is for sale
			owner = "For Sale - Press F2"
			if (bit.band(self:GetDTInt(3), OBJ_SEALED) == OBJ_SEALED) then
				owner = ""
			end
		end
		lines:Add("Owner", owner, color_white, 3);
	else
		name = self:GetNWString("Name", "Entity");
		name = (name:find"^[aeiouAEIOU]" and "An" or "A") .. " " .. name;
	end
	lines:Add("Name", name, color_purpleblue, 1);
	local status = self:GetStatus();
	if (status ~= "") then
		lines:Add("Status", status, color_yellow, 2);
	end
end
