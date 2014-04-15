CAT.Name = "Drinks";
CAT.Description = "Some drinks for the boring people.";
if (not (GM or GAMEMODE):GetPlugin("hunger")) then
	CAT.NoShow = true;
end
