--
-- ~ Drug Lab ~
-- ~ Applejack ~
--
if (not GM.Config["Contraband"]["cider_drug_lab"]) then
	return
end

ITEM.Name = "Drug Lab";
ITEM.Plural = "Drug Labs";
ITEM.Cost = 350;
ITEM.Model = "models/props_combine/combine_mine01.mdl";
ITEM.Batch = 1;
ITEM.Store = true;
ITEM.Description = "A drug lab that earns you money over time.";
ITEM.Base = "contraband"
