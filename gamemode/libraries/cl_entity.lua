--
-- ~ Clientside Entity Library ~
-- ~ Applejack ~
--
GM.AccessableEntities = {};
local queue = {};
local function entgranted(ent, access)
	ent._HasAccess = access;
	GM.AccessableEntities[ent] = access;
	if GetConVarNumber "developer" > 0 then
		local moneyAlert = {}

		-- Set some information for the money alert.
		local words = ent:GetNWString("Name", "Door") .. ", " ..
              			tostring(ent:GetDisplayName())
		moneyAlert.alpha = 255
		moneyAlert.add = 1

		if access then
			moneyAlert.color = color_white
			moneyAlert.text = "+ " .. words
		else
			moneyAlert.color = color_black
			moneyAlert.text = "- " .. words
		end
		debugoverlay.Line(
			LocalPlayer():EyePos() + LocalPlayer():GetForward(), ent:GetPos(), 20,
			moneyAlert.color, true
		)
		print(
			"[DEBUG] Your access for " .. tostring(ent) .. "['" .. words ..
				"'] has been set to '" .. tostring(access) .. "'."
		)
	end
end
local function handleent(num, status)
	local ent = Entity(num)
	if (IsValid(ent)) then
		entgranted(ent, status);
	else
		queue[num] = status;
	end
end

usermessage.Hook(
	"AccessChange", function(msg)
		handleent(msg:ReadShort(), msg:ReadBool() or nil);
	end
);

usermessage.Hook(
	"AccessReset", function(msg)
		for ent in pairs(GM.AccessableEntities) do
			if (IsValid(ent)) then
				entgranted(ent, nil);
			end
		end
		local lim = msg:ReadShort();
		if (lim == 0) then
			return;
		end
		for i = 1, lim do
			handleent(msg:ReadShort(), true);
		end
	end
);

timer.Create(
	"Applejack - Entity Library - Table Cleaner", GM.Config["Earning Interval"], 0,
	function()
		for ent in pairs(GM.AccessableEntities) do
			if not IsValid(ent) then
				GM.AccessableEntities[ent] = nil
			end
		end
	end
)
