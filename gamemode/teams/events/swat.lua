TEAM.Name = "SWAT";
TEAM.Description =
	"The SWAT team is called in if the police force cannot handle the situation.";
TEAM.Color = Color(46, 56, 120);
TEAM.Invisible = true;
TEAM.GroupLevel = GROUP_TWIG;
TEAM.Salary = 0;
TEAM.Models = {
	Male = {"models/player/riot.mdl"},
	Female = {"models/player/riot.mdl"},
};
TEAM.StartingEquipment = {
	Ammo = {smg1 = 1200, grenade = 1},
	Weapons = {"cider_mp5", "cider_baton", "weapon_real_cs_flash"},
};
