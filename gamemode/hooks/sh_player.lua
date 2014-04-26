--[[
	~ Shared Player Hooks ~
	~ Applejack ~
--]]

---
-- Called when a player attempts to join a team (server) or the job list is updated (client)
-- @param ply The player in question
-- @param target The target team's ID
-- @return True if they can, False if they can't.
function GM:PlayerCanJoinTeamShared(ply, target)
	local tdata = team.Get(target);
	if (not tdata or tdata.Invisible) then
		return false, "Invalid team!";
	--elseif (team.NumPlayers(tdata.TeamID) >= tdata.SizeLimit) then
	--    return false, "That team is full!";
	end

	local mdata = ply:GetTeam();
	if (not mdata) then
		-- FIXME: Maybe only return true for the citizen?
		return true; -- If they're not in a cider team we shouldn't block them from joining one.
	end
	local tlevel, mlevel = tdata.GroupLevel, mdata.GroupLevel;
	if(tdata.Group ~= mdata.Group) then -- We're moving between groups
		-- While not immediately apprent, this returns true if they are switching from level 1 to level 1 and takes advantage of the fact that the message is not displayed if 'true' is returned.
		return (tlevel == mlevel and mlevel == GROUP_BASE), "You can only swap groups from the base!";
	end
	if (tlevel == GROUP_BASE) then -- We're trying to drop ourselves to the base. This is fine.
		return true;
	elseif (tlevel ~= (mlevel + 1) and tlevel ~= (mlevel - 1)) then -- You can only move up and down the tree one step at a time. (There aren't very many levels but if there are ever more this will be more active.
		return false, "You cannot join that team straight away!";
	end
	local tgang, mgang = tdata.Gang, mdata.Gang;
	if (tgang == mgang) then -- You can move about in your gang with no issues
		return true;
	elseif (mlevel == GROUP_BASE) then -- If we're in the base and want to enter a gang, that's also fine.
		return true;
	end
	-- We're trying to swap gangs. This isn't allowed.
	return false, "You cannot change gangs!";
end
---
-- Called when a player attempts to demote another player.
-- @param ply The player attempting
-- @param target The intended victim
-- @return true if they can false if they can't
function GM:PlayerCanDemote(ply, target)
	local err = ""
	if target:Team() == TEAM_DEFAULT then
		return false, "You cannot demote players from the default team!";
	elseif (target:Arrested() or target:Tied()) then
		return false, "You cannot demote "..target:Name().." right now!";
	elseif ply:IsModerator() then
		return true
	end
	local tdata, mdata = target:GetTeam(), ply:GetTeam();
	if (not (tdata and mdata)) then return false; end
	if (mdata.GroupLevel ~= GROUP_GANGBOSS) then
		return false, "Only the leader can demote players from their gang.";
	elseif (mdata.Gang ~= tdata.Gang) then
		return false, "You can only demote players in your own gang!";
	end
	return true;
end

-- Called when a player attempts to noclip.
function GM:PlayerNoClip(ply)
	if (ply:Arrested() or ply:KnockedOut() or ply:Tied() or not ply:IsAdmin()) then
		return false
	end
	return true;
end

---
-- Called when a player looks at the store menu or tries to manufacture an item. (IE: Be quiet)
-- @param ply The player in question
-- @param category The ID of the category in question
-- @return True if they can, false if they can't.
function GM:PlayerCanManufactureCategory(ply, category)
	local t = ply:GetTeam();
	if (not t) then return false; end
	for _, cat in pairs(t.CanMake) do
		if (cat == category) then
			return true;
		end
	end
	for _, cat in pairs(t.Group.CanMake) do
		if (cat == category) then
			return true;
		end
	end
	if (t.Gang) then
		for _, cat in pairs(t.Gang.CanMake) do
			if (cat == category) then
				return true;
			end
		end
	end
	return false;
end
