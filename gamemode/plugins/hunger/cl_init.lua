--[[
	~ Hunger Plugin / CL ~
	~ Applejack ~
--]]

local num
GM:AddHUDBar("Hunger", Color(50, 255, 50), function()
	num = lpl._Hunger or 0;
	return num > 25 and num or -1;
end);