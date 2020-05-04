--
-- ~ Gamemode hooks for arrestation ~
-- ~ Applejack ~
--
---
-- Called when a player attempts to unwarrant a player.
-- @param ply The player in question
-- @param target The player's intended victim
-- @return True if they can, false if they can't.
function GM:PlayerCanUnwarrant(ply, target)
	return ply:IsAdmin() -- Let admins circumnavagate the system. (HAAAX!)
end

---
-- Called when a player has been warranted
-- @param ply The player in question
-- @param class The class of warrant
function GM:PlayerWarranted(ply, class)
end

---
-- Called when a player has been unwarranted either due to direct action or the time expiring
-- @param ply The player in question
function GM:PlayerUnwarranted(ply)
end

-- Called when a player attempts to arrest another player.
function GM:PlayerCanArrest(ply, target)
	if (target._Warranted == "arrest") then
		return true
	else
		ply:Notify(target:Name() .. " does not have an arrest warrant!", 1)
		-- Return false because the target does not have a warrant.
		return false
	end
end

-- Called when a player attempts to unarrest a player.
function GM:PlayerCanUnArrest(ply, target)
	return true
end

---
-- Called when a player is arrested
-- @param ply The player in question
function GM:PlayerArrested(ply)
end

---
-- Called when a player is unarrested
-- @param ply The player in question
function GM:PlayerUnArrested(ply)
end
