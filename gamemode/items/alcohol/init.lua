CAT.Name = "Alcohol";
CAT.Description = "A lovely collection of drinkypoos.";
if (not (GM or GAMEMODE):GetPlugin("hunger")) then
	CAT.NoShow = true;
end