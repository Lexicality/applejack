PLUGIN.Name = "Packaging"
function PLUGIN:PlayerCanManufactureCategory(ply, category)
	if (category == CATEGORY_PACKAGING and ply:Team() == TEAM_SUPPLIER) then
		return true;
	end
end
