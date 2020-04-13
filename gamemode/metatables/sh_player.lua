--
-- ~ Shared Player metatable ~
-- ~ Applejack ~
--
---
-- The shared player metatable
-- @name meta
-- @class table
local meta = _R.Player;
if (not meta) then
	error(
		"[" .. os.date() .. "] Applejack Shared Player metatable: No metatable found!"
	);
end

---
-- A shorthand check to see if a player is a moderator or higher.
-- @return true if they are, false if not.
function meta:IsModerator()
	return self:IsAdmin() or self:GetNWBool("Moderator");
end

---
-- Gets the physical ragdoll made by player:KnockOut().
-- @return A vaild entity if the player is ragdolled, NULL else.
function meta:GetRagdollEntity()
	return self:GetNWEntity("Ragdoll");
end
meta.GetEntityPos = _R.Entity.GetPos;

---
-- An override of the GetPos function in the base entity metatable.
-- Takes into account that the player may be rolling about on the floor.
-- @return The position of the player's ragdoll if valid, otherwise the position of the player's entity.
function meta:GetPos()
	local ragdoll = self:GetRagdollEntity();
	if IsValid(ragdoll) then
		return ragdoll:GetPos();
	else
		return self:GetEntityPos();
	end
end

---
-- Checks if the player has been ragdolled
-- @return true if they are, false if they're not.
function meta:KnockedOut()
	return self:GetNWBool "KnockedOut";
end

---
-- Checks if the player has been tied up
-- @return true if they are, false if they're not.
function meta:Tied()
	return self:GetNWBool "Tied";
end

---
-- Checks if the player has been arrested
-- @return true if they are, false if they're not.
function meta:Arrested()
	return self:GetNWBool "Arrested";
end

---
-- Checks if the player has a warrant against him
-- @return true if they are, false if they're not.
function meta:Warranted()
	return self:GetNWString("Warrant") ~= "";
end

---
-- Get's the warrant against the player
-- @return The warrant name or ""
function meta:GetWarrant()
	return self:GetNWString("Warrant");
end

---
-- Get the data table for the player's current team
-- @return team.Get(self:Team())
function meta:GetTeam()
	return team.Get(self:Team());
end

---
-- Get the data table for the player's current group
-- @return The Group table
function meta:GetGroup()
	return team.Query(self:Team(), "Group");
end

---
-- Get the data table for the player's current gang
-- @return The Gang table or nil if they're not in a gang
function meta:GetGang()
	return team.Query(self:Team(), "Gang");
end
