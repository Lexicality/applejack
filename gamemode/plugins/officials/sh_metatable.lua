--
-- ~ Arrests, warrants etc ~
-- ~ Applejack ~
--
local plymeta = _R.Player;
AddCSLuaFile()

---
-- Checks if the player has been arrested
-- @return true if they are, false if they're not.
function plymeta:Arrested()
	return self:GetNWBool "Arrested";
end

---
-- Checks if the player has a warrant against him
-- @return true if they are, false if they're not.
function plymeta:Warranted()
	return self:GetNWString("Warrant") ~= "";
end

---
-- Get's the warrant against the player
-- @return The warrant name or ""
function plymeta:GetWarrant()
	return self:GetNWString("Warrant");
end
