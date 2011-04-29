--[[
	~ Stamina Plugin / CL ~
	~ Applejack ~
--]]

local num
GM:AddHUDBar("Stamina", Color(50, 50, 255), function()
	num = lpl._Stamina or 100;
	return num < 100 and num or -1;
end);

-- Called when the local player presses a bind.
function PLUGIN:PlayerBindPress(player, bind, pressed)
	if (player:InVehicle()) then return; end
	local stamina = LocalPlayer()._Stamina or 100;
	
	-- Check if the stamina is smaller than 10.
	if not player:KnockedOut()
	and player:GetNWBool"Exausted"
	and bind:find"+jump" then
		return true;
	end
end