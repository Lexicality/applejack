--
-- ~ Poliskar ~
-- ~ Applejack ~
--
ITEM.Name = "Police Car";
ITEM.Cost = 100000;
ITEM.Model = "models/copcar.mdl";
ITEM.Store = true;
ITEM.Plural = "Police Cars";
ITEM.Description = "A police cruiser";
ITEM.VehicleName = "copcar"
ITEM.Base = "vehicle"

local officials = (GM or GAMEMODE):GetPlugin("officials");
if (officials) then
	function ITEM:CanSpawn(ply)
		if (not officials:IsAuthorised(ply, true)) then
			ply:Notify("Only the police can spawn those!", 1);
			return false;
		end
		return true;
	end
end
