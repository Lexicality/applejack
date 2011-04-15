if (not GM:GetPlugin("hunger")) then
	TEAM.Valid = false; -- Invalidate the team if there aint no plugin
end
TEAM.Name = "Chef";
TEAM.Description = "A creates and sells food.";
TEAM.Color = Color(255,125,200);
TEAM.GroupLevel = GROUP_MERCHANT;
TEAM.CanMake = {CATEGORY_FOOD};
TEAM.SizeLimit = 4;