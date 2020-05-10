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

-- Warrant
GM:AddDynamicHUDBox(
	function(box)
		local text = lpl:GetNWString("Warrant")
		if (text == "") then
			return -1;
		end
		return "You have " .. (text == "arrest" and "an" or "a") .. " " .. text ..
       			" warrant!";
	end, "icon16/page_white_text.png"
)

-- Arrested
GM:AddStaticHUDBox(
	"You have been arrested.", "icon16/lock.png", function(box)
		return lpl:Arrested();
	end
);

GM:AddHUDBar(
	"Arrest Time: 0:00", color_red, function(bar)
		local num = (lpl._UnarrestTime or 0) - CurTime()
		if (num <= 0) then
			return -1
		end
		bar.text = "Arrest Time: " .. string.ToMinutesSeconds(num)
		return (num / MS.Config["Arrest Time"]) * 100;
	end
);

function PLUGIN:AdjustESPLines(ent, class, lines, pos, dist, centre)
	if not ent:IsPlayer() then
		return
	end
	if ent:Arrested() then
		lines:Add("Status", "(Arrested)", color_red, 3);
	end
	local warrant = ent:GetWarrant();
	if (warrant ~= "") then
		if (warrant == "arrest") then
			lines:Add("Warrants", "(Arrest Warrant)", color_red, 4);
		elseif (warrant == "search") then
			lines:Add("Warrants", "(Search Warrant", color_lightblue, 4);
		end
	end
end
