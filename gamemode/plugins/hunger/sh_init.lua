--[[
	~ Hunger Plugin / SH ~
	~ Applejack ~
--]]

PLUGIN.Name = "Hunger";
function PLUGIN:PlayerCanManufactureCategory(ply, category)
    if (ply:Team() == TEAM_CHEF and
       (category == CATEGORY_FOOD or category == CATEGORY_ALCOHOL)) then
        return true;
    end
end
