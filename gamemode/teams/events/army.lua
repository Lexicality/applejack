TEAM.Name = "US Army";
TEAM.Description = "The US army is a group of bacon grease covered yanks.";
TEAM.Color = Color(12,71,0);
TEAM.Invisible = true;
TEAM.Models = {
	Male = {
		"models/player/dod_american.mdl"
	};
	Female = {
		"models/player/dod_american.mdl"
	};
};
TEAM.GroupLevel = GROUP_TWIG;
TEAM.Salary = 0;
TEAM.StartingEquipment = {
	Ammo = {
		smg1 = 1200;
	};
	Weapons = {
		"cider_m4a1";
	};
};
TEAM.CanMake = {
	CATEGORY_AMMO;
	CATEGORY_FOOD;
};

