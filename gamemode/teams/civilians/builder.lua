if (true or not GM:GetPlugin("builders")) then
	TEAM.Valid = false; -- Invalidate the team if there aint no plugin
end
TEAM.Name = "Builder";
TEAM.Description =
	"Builds props for $150 per prop, non-refundable. 15 Minutes of usage max, 15 props max.";
TEAM.Color = Color(90, 230, 20);
TEAM.Salary = 100;
TEAM.Cooldown = 900;
TEAM.TimeLimit = 900;
TEAM.Models.Male = {"models/player/barney.mdl"};
TEAM.Models.Female = TEAM.Models.Male;
TEAM.SizeLimit = 2;
