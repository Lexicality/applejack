--
-- ~ Officials Plugin / CL ~
-- ~ Applejack ~
--
local arrestwarrant = Color(255, 50, 50, 255)
local spawnimmunity = Color(150, 255, 75, 255)

local time, timeleft;
local function spawnImmunity(hudBox)
	time = lpl._SpawnImmunityTime;
	if (not (time > 0 and lpl:Alive() and lpl:Team() == TEAM_MAYOR)) then
		return -1;
	end
	timeleft = math.ceil(time - CurTime());
	if (timeleft <= 0) then
		lpl._SpawnImmunityTime = 0;
		return -1;
	end
	return "You have spawn immunity for: " .. timeleft .. " second" ..
       		(timeleft > 1 and "s" or "");
end
GM:AddDynamicHUDBox(spawnImmunity, nil) -- TODO: Silkicon for spawn immunity.

function PLUGIN:LocalPlayerCreated(ply)
	ply._SpawnImmunityTime = 0;
end

local function live()
	return GetGlobalBool("lockdown");
end

local last = false;
function PLUGIN:Think()
	local LD = live();
	if (LD ~= last and LD == true) then
		GM:AddPermaNotification(
			"A lockdown is in progress. Please return to your home.", live, color_red
		);
		last = LD;
	end
end

-- TODO: Spawn immunity bar using CSVar hooks
