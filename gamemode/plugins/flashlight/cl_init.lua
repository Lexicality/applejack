--[[
	~ Flashlight Plugin / CL ~
	~ Applejack ~
--]]
local num
GM:AddHUDBar("Flashlight", Color(225, 75, 200), function()
	num = lpl._Flashlight or 100;
	if (num == -1 or num == 100) then
		return -1;
	end
	return num;
end);