--
-- ~ Stamina Plugin / SV ~
-- ~ Applejack ~
--

-- Called when a player spawns.
function PLUGIN:PostPlayerSpawn(ply, lightSpawn, changeTeam)
	if (not lightSpawn) then
		ply._Stamina = 100;
	end
end

-- Called when a player presses a key.
function PLUGIN:KeyPress(ply, key)
	if  (not (ply:InVehicle() or ply:Arrested() or ply:Tied() or ply:GetNWBool"cider_Exhausted")
	and (ply:Alive() and not ply:KnockedOut())
	and (ply:IsOnGround() and key == IN_JUMP)) then
		ply._Stamina = math.Clamp(ply._Stamina - 5, 0, 100);
	end
end

-- Called every tenth of a second that a player is on the server.
function PLUGIN:PlayerTenthSecond(ply)
	local inVehicle = ply:InVehicle();
	if (ply:Arrested() or ply:Tied() or ply._HoldingEnt or (ply:GetMoveType() == MOVETYPE_NOCLIP and not (inVehicle and ply._Stamina < 100))) then
		return;
	end
	if (not inVehicle and ply:KeyDown(IN_SPEED) and ply:Alive() and not ply:KnockedOut() and not ply:GetNWBool"Exhausted"
	and ply:GetVelocity():Length() > 0) then
		if (ply:Health() < 50) then
			ply._Stamina = math.max(ply._Stamina - (GM.Config["Stamina Drain"] + ( ( 50 - ply:Health() ) * 0.05 ) ), 0);
		else
			ply._Stamina = math.max(ply._Stamina - GM.Config["Stamina Drain"], 0 );
		end
	else
		if (ply:Health() < 50) then
			ply._Stamina = math.min(ply._Stamina + (GM.Config["Stamina Restore"] - ( ( 50 - ply:Health() ) * 0.0025 ) ), 100);
		else
			ply._Stamina = math.min(ply._Stamina + GM.Config["Stamina Restore"], 100);
		end
	end

	-- Check the player's stamina to see if it's at it's maximum.
	if (ply._Stamina <= 1) then
		ply:Incapacitate();
		ply:SetNWBool("Exhausted", true)
	elseif ply:GetNWBool"Exhausted" then
		if (ply._Stamina >= 25) then
			ply:SetNWBool("Exhausted", false);
			ply:Recapacitate();
		end
		-- If you get exhausted, it takes a while to wear off. ;)
	else
		local r = ply._Stamina / 100
		ply:SetRunSpeed((GM.Config["Run Speed"] - GM.Config["Walk Speed"]) * r + GM.Config["Walk Speed"]);
		ply:SetWalkSpeed((GM.Config["Walk Speed"] - GM.Config["Incapacitated Speed"]) * r + GM.Config["Incapacitated Speed"]);
	end

	-- Set it so that we can get the player's stamina client side.
	ply:SetCSVar(CLASS_LONG, "_Stamina", math.Round(ply._Stamina) );
end

function PLUGIN:PlayerCanBeRecapacitated(ply)
	if (ply:GetNWBool("Exhausted")) then
		return false;
	end
end
