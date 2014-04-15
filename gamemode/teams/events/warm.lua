TEAM.Name        = "Wehrmacht";
TEAM.Description = "The Wehrmacht is an elite force of German soldiers.";
TEAM.Color       = Color(120,86,86);
TEAM.Invisible   = true;
TEAM.GroupLevel  = GROUP_TWIG;
TEAM.Salary      = 0;
TEAM.Models = {
	Male = {
		"models/player/dod_german.mdl"
	};
	Female = {
		"models/player/dod_german.mdl"
	};
};
TEAM.StartingEquipment = {
	Ammo = {
		smg1 = 1200;
	};
	Weapons = {
		"cider_ak47";
	};
};
TEAM.CanMake = {
	CATEGORY_AMMO;
	CATEGORY_FOOD;
};
