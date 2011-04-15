--[[
	~ Builders Plugin ~
	~ Applejack ~
--]]

function PLUGIN:PlayerCanSpawnProp(ply, mdl)
	if (ply:Team() ~= TEAM_BUILDER) then
		return;
	end
	if (ply:GetCount("props") > self.Config["Builder Prop Limit"]) then
		ply:Notify("You hit the prop limit!",1)
		return false;
	end
	local afford, costing = ply:CanAfford(self.Config["Builder Prop Cost"]);
	if (not afford) then
		ply:Notify("You need another $" .. costing .. " to spawn this prop!", 1);
		return false;
	end
	--return gamemode.Call("PlayerCanSpawnProp", ply, mdl);
end

local function tmr(ply)
	if (IsValid(ply)) then
		ply._NextSpawnProp = CurTime() + 15
	end
end

function PLUGIN:PlayerSpawnedProp(ply, mdl, ent)
	if (ply:Team() == TEAM_BUILDER) then
		ply:GiveMoney(-self.Config["Builder Prop Cost"])
		timer.Simple(0, tmr, ply);
	end 
end

-- Stop silly donators plugging holes.
function PLUGIN:PlayerCanJoinTeam(ply, tid)
	if (tid == TEAM_BUILDER and ply:HasAccess("e")) then
		ply:Notify("You do not need to join this team!");
		return false;
	end
end

function PLUGIN:PlayerLoadout(ply)
	if (ply:Team() == TEAM_BUILDER) then
		ply:Give("weapon_physgun");
	end
end