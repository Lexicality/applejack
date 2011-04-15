if (not GM:GetPlugin("officials")) then
	GROUP.Valid = false;
end
GROUP.Name = "Officials";
GROUP.Description = "The city government in charge of looking after the citizens.";
GROUP.CantUse = {
	CATEGORY_ILLEGAL_WEAPONS;
	CATEGORY_ILLEGAL_GOODS;
	CATEGORY_EXPLOSIVES;
};
GROUP.Model = "models/player/Hostage/Hostage_01.mdl";