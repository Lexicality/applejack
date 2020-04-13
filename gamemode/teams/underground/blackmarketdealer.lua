TEAM.Name = "Black Market Dealer";
TEAM.Description = "Deals illegal goods.";
TEAM.Color = Color(125, 125, 125);
TEAM.CanMake = {
	CATEGORY_EXPLOSIVES,
	CATEGORY_CONTRABAND,
	CATEGORY_POLICE_WEAPONS,
	CATEGORY_ILLEGAL_GOODS,
	CATEGORY_ILLEGAL_WEAPONS,
	CATEGORY_AMMO,
};
TEAM.Models.Male = {"models/player/Group03m/Male_04.mdl"};
TEAM.Models.Female = {"models/player/Group03m/Female_04.mdl"};
TEAM.GroupLevel = GROUP_MERCHANT;
TEAM.PossessiveString = "The %s";
TEAM.SizeLimit = 2;
TEAM.Salary = 100;
