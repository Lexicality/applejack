--[[
	~ Money Printer ~
	~ Applejack ~
--]]

if (not GM.Config["Contraband"]["cider_drug_lab"]) then return end


ITEM.Name			= "Money Printer";
ITEM.Plural			= "Money Printers";
ITEM.Cost			= 750;
ITEM.Model			= "models/props_c17/consolebox01a.mdl";
ITEM.Batch			= 1;
ITEM.Store			= true;
ITEM.Description	= "A money printer that earns you money over time.";
ITEM.Base			= "contraband"
