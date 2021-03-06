TEAM.Name = "Quartermaster";
TEAM.Description = "Supplies the police with their needs";
TEAM.Color = Color(50, 200, 255);
TEAM.CantUse = {CATEGORY_WEAPONS, CATEGORY_POLICE_WEAPONS};
TEAM.CanMake = {CATEGORY_WEAPONS, CATEGORY_POLICE_WEAPONS, CATEGORY_AMMO};
TEAM.Models.Male = {
	"models/player/Hostage/Hostage_02.mdl",
	"models/player/Hostage/Hostage_03.mdl",
};
TEAM.Models.Female = TEAM.Models.Male;
TEAM.GroupLevel = GROUP_MERCHANT;
TEAM.PossessiveString = "The %s";
TEAM.SizeLimit = 1;
TEAM.Salary = 225;
