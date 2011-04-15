--[[
	~ Base packaging ~
	~ Applejack ~
--]]
include("item.lua");
ITEM.Capacity	= 20
ITEM.AutoClose	= true
ITEM.NoVehicles = true;
local plugin = (GM or GAMEMODE):GetPlugin("packaging");
function ITEM:onUse(player)
	return plugin:CrateTime(player,self)
end