TEAM.Name = "Vault 107 Security";
TEAM.Description = "Security personel of Vault 107. Do not mess with them.";
TEAM.Color = Color(166,175,7);
TEAM.Invisible = true;
TEAM.Models = {
	Male = {
		"models/player/police.mdl"
	};
	Female = {
		"models/player/police.mdl"
	};
};
TEAM.GroupLevel = GROUP_TWIG;
TEAM.Salary = 0;
TEAM.StartingEquipment = {
	Ammo = {
		pistol = 600;
	};
	Weapons = {
		"weapon_stunstick";
		"weapon_pistol";
	};
};
TEAM.CanMake = {
	CATEGORY_FOOD;
};

