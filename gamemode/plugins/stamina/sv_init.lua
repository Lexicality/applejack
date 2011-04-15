--[[
	~ Stamina Plugin / SV ~
	~ Applejack ~
--]]

-- Called when a player spawns.
function PLUGIN:PostPlayerSpawn(ply, lightSpawn, changeTeam)
	if (not lightSpawn) then
		ply._Stamina = 100;
	end
end

-- Called when a player presses a key.
function PLUGIN:KeyPress(ply, key)
	if  (not (ply:Arrested() or ply:Tied() or ply:GetNWBool"cider_Exausted")
	and (ply:Alive() and not ply:KnockedOut())
	and (ply:IsOnGround() and key == IN_JUMP)) then
		ply._Stamina = math.Clamp(ply._Stamina - 5, 0, 100);
	end
end

-- Called every tenth of a second that a player is on the server.
function PLUGIN:PlayerTenthSecond(ply)
	if (ply:Arrested() or ply:Tied() or ply._HoldingEnt or ply:GetMoveType() == MOVETYPE_NOCLIP) then
		return;
	end
	if (ply:KeyDown(IN_SPEED) and ply:Alive() and not ply:KnockedOut() and not ply:GetNWBool"Exausted"
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
		ply:SetNWBool("Exausted", true)
	elseif ply._Stamina <= 50 and ply:GetNWBool"Exausted" then
		-- If you get exausted, it takes a while to wear off. ;)
	else
		local r = ply._Stamina / 100
		ply:SetRunSpeed((GM.Config["Run Speed"] - GM.Config["Walk Speed"]) * r + GM.Config["Walk Speed"]);
		ply:SetWalkSpeed((GM.Config["Walk Speed"] - GM.Config["Incapacitated Speed"]) * r + GM.Config["Incapacitated Speed"]);
		ply:SetNWBool("Exausted", false)
	end
	
	-- Set it so that we can get the player's stamina client side.
	ply:SetCSVar(CLASS_LONG, "_Stamina", math.Round(ply._Stamina) );
end

function PLUGIN:PlayerCanBeRecapacitated(ply)
	if (ply:GetNWBool("Exausted")) then
		return false;
	end
end