--[[
	~ Baton ~ Serverside ~
	~ Applejack ~
--]]
includecs("shared.lua");
AddCSLuaFile("cl_init.lua");

function SWEP:GetTarget()
	-- Compensate lag for the owner.
	if (self.Owner.LagCompensation) then
		self.Owner:LagCompensation(true);
	end

	local tr = self.Owner:GetEyeTraceNoCursor();

	-- Uncompensate lag for the owner.
	if (self.Owner.LagCompensation) then
		self.Owner:LagCompensation(false);
	end

	local ent = tr.Entity;
	if (not IsValid(ent) or tr.StartPos:Distance(tr.HitPos) > 128) then
		return false;
	elseif(IsValid(ent._Player)) then -- Player Ragdoll
		ent = ent._Player;
	elseif (ent:IsVehicle()) then
		if (ent:GetClass() ~= "prop_vehicle_jeep") then
			ent = ent:GetDriver();
		else
			tr = util.QuickTrace(tr.HitPos, tr.Normal * 512, ent);
			if (IsValid(tr.Entity)) then
				ent = tr.Entity;
				if (ent:IsVehicle() and ent:GetClass() == "prop_vehicle_prisoner_pod" and IsValid(ent:GetDriver())) then
					ent = ent:GetDriver();
				elseif (not(ent:IsPlayer() and ent:InVehicle())) then
					return false;
				end
			end
		end
	end
	if (ent:IsPlayer() and not (ent:Alive() and (ent:GetMoveType() ~= MOVETYPE_NOCLIP or ent:InVehicle()))) then
		return false;
	end
	return ent;
end
					

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:DoHitEffects()
	
	local ply = self:GetTarget();	
	if (not ply) then return false; end
	
	if (not ply:IsPlayer()) then
		local ent = ply;
		if (GM.Config["Contraband"][ent:GetClass()]) then
			ent:TakeDamage(ent:Health(), self.Owner, self.Owner);
		end
		return false;
	elseif (not ply:Alive()) then
		return false;
	elseif (self.Owner:KeyDown(IN_USE)) then
		if( not gamemode.Call("PlayerCanStun", self.Owner, ply)) then return false; end
		-- Use key is down, violence time.
		ply:TakeDamage(10, self.Owner, self.Owner);
		-- Knock the victim back a little
		ply:SetLocalVelocity(256 * (ply:GetPos() - self.Owner:GetPos()):Normalize());
	elseif (ply:KnockedOut()) then
		if (not gamemode.Call("PlayerCanWakeUp", self.Owner, ply)) then return false; end
		-- Wake 'em Upp
		ply:WakeUp();
		GM:Log(EVENT_POLICEEVENT, "%s woke up %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerWokenUp", ply, self.Owner);
	elseif (gamemode.Call("PlayerCanKnockOut", self.Owner, ply)) then
		if (ply:InVehicle()) then ply:ExitVehicle() end
		ply:KnockOut(60);
		if (ply.ragdoll) then
			ply.ragdoll.time = CurTime() + 2;
		end
		ply._Stunned = true;
		GM:Log(EVENT_POLICEEVENT, "%s knocked out %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerKnockedOut", ply, self.Owner);
	end
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:DoHitEffects()
	
	local ply = self:GetTarget();
	
	if (not ply) then return false; end
	
	if (not ply:IsPlayer()) then
		local ent = ply;
		if (ent:IsDoor() and gamemode.Call("PlayerCanRamDoor", self.Owner, ent)) then
			GM:OpenDoor(ent, 0.25, true, gamemode.Call("PlayerCanJamDoor", self.Owner, ent));
		end
	elseif (ply:Arrested()) then
		if (not gamemode.Call("PlayerCanUnArrest", self.Owner, ply)) then return false; end
		if (ply:KnockedOut()) then
			ply:WakeUp();
		elseif (ply:InVehicle()) then
			ply:ExitVehicle();
		end
		GM:Log(EVENT_POLICEEVENT, "%s unarrested %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerUnarrest", self.Owner, ply);
	elseif (gamemode.Call("PlayerCanArrest", self.Owner, ply)) then
		if (ply:KnockedOut()) then
			ply:WakeUp();
		elseif (ply:InVehicle()) then
			ply:ExitVehicle();
		end
		ply:Arrest();
		GM:Log(EVENT_POLICEEVENT, "%s arrested %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerArrest", self.Owner, ply);
	end
end
