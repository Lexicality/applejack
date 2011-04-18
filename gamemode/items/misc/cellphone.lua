--[[
	~ Phone ~
	~ Applejack ~
--]]

ITEM.Name			= "Phone";
ITEM.Size			= 1;
ITEM.Cost			= 1000;
ITEM.Model			= "models/props/cs_office/phone_p2.mdl";
ITEM.Batch			= 10;
ITEM.Store			= true;
ITEM.Plural			= "Phones";
ITEM.Description	= "Fuck da... Prank call da polis!";
ITEM.Base			= "item";

function ITEM:onUpdate(ply,number)
	ply._Phone	= number >= 1;
end