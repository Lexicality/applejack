--[[
	~ Baton ~ Serverside ~
	~ Applejack ~
--]]
includecs("shared.lua");
AddCSLuaFile("cl_init.lua");

function SWEP:GetTarget()
	-- Compensate lag for the owner.
	self.Owner:LagCompensation(true);

	local tr = self.Owner:GetEyeTraceNoCursor();

	-- Uncompensate lag for the owner.
	self.Owner:LagCompensation(false);

	local ent = tr.Entity;
	if (not IsValid(ent) or tr.StartPos:Distance(tr.HitPos) > 128) then
		return false;
	elseif (IsValid(ent._Player)) then -- Player Ragdoll
		ent = ent._Player;
	elseif (ent:IsVehicle()) then
		-- Check if it's a chair
		if (ent:GetClass() ~= "prop_vehicle_jeep") then
			ent = ent:GetDriver();
		else
			-- TODO: Do some kind of bounding box magic to see if the baton hits a person's position, rather
			--        than checking if you hit them, since players in vehicles have bizzare hitboxes.

			-- Penetrate through the car and try to hit someone inside
			tr = util.QuickTrace(tr.HitPos, tr.Normal * 512, ent);
			if (IsValid(tr.Entity)) then
				ent = tr.Entity;
				-- Have we hit a chair (ie a passenger)
				if (ent:IsVehicle() and ent:GetClass() == "prop_vehicle_prisoner_pod" and IsValid(ent:GetDriver())) then
					ent = ent:GetDriver();
				-- Have we hit the driver? (I doubt it, it's bloody hard to hit the driver)
				elseif (not (ent:IsPlayer() and ent:InVehicle())) then
					return false;
				end
			end
		end
	end
	-- Make sure we don't try to get players or admins in noclip.
	-- Unhelpfully people in vehicles are techincally in noclip too, so deal with that.
	if (ent:IsPlayer() and not (ent:Alive() and (ent:GetMoveType() ~= MOVETYPE_NOCLIP or ent:InVehicle()))) then
		return false;
	end
	return ent;
end


-- Called when the player attempts to primary fire, in this case knockout/wakeup and sometimes maim.
function SWEP:PrimaryAttack()
	self:OnAttack();

	-- Grab our victim and give up if we don't like them.
	local ply = self:GetTarget();
	if (not ply) then return false; end

	-- Sometimes careless officers hit things that aren't people
	if (not ply:IsPlayer()) then
		local ent = ply;
		-- Primary fire on contraband = instaboom. (woo)
		if (GM.Config["Contraband"][ent:GetClass()]) then
			ent:TakeDamage(ent:Health(), self.Owner, self.Owner);
		end
	-- If the player has their use modifier on, then generate assault lawsuits.
	elseif (self.Owner:KeyDown(IN_USE)) then
		-- Hooks hooks, good for your heart, the more you use, the less people have to modify your code.
		if (not gamemode.Call("PlayerCanStun", self.Owner, ply)) then
			return false;
		end
		-- Violence time.
		ply:TakeDamage(10, self.Owner, self.Owner);
		-- Knock the victim back a little
		ply:SetLocalVelocity(256 * (ply:GetPos() - self.Owner:GetPos()):Normalize());
	-- Wake up the slumbering.
	elseif (ply:KnockedOut()) then
		-- Check they're allowed to.
		if (not gamemode.Call("PlayerCanWakeUp", self.Owner, ply)) then
			return false;
		end
		-- Wake 'em Upp
		ply:WakeUp();
		GM:Log(EVENT_POLICEEVENT, "%s woke up %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerWokenUp", ply, self.Owner);
	-- And stun the unslumbering.
	elseif (gamemode.Call("PlayerCanKnockOut", self.Owner, ply)) then
		-- Save us from some rather annoying glitches
		if (ply:InVehicle()) then
			ply:ExitVehicle()
		end
		ply:KnockOut(60);
		if (ply.ragdoll) then
			ply.ragdoll.time = CurTime() + 2;
		end
		ply._Stunned = true;
		GM:Log(EVENT_POLICEEVENT, "%s knocked out %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerKnockedOut", ply, self.Owner);
	end
end

-- Called when the player attempts to secondary fire, for arresterating and blowing up doors.
function SWEP:SecondaryAttack()
	self:OnAttack();

	-- Grab our victim and give up if we don't like them.
	local ply = self:GetTarget();
	if (not ply) then return false; end

	-- Sometimes careless officers hit things that aren't people
	if (not ply:IsPlayer()) then
		local ent = ply;
		-- Secondary fire + door = instaboom. (Woo some more)
		if (ent:IsDoor() and gamemode.Call("PlayerCanRamDoor", self.Owner, ent)) then
			GM:OpenDoor(ent, 0.25, true, gamemode.Call("PlayerCanJamDoor", self.Owner, ent));
		end
	elseif (ply:Arrested()) then
		if (not gamemode.Call("PlayerCanUnArrest", self.Owner, ply)) then
			return false;
		end
		if (ply:KnockedOut()) then
			ply:WakeUp();
		elseif (ply:InVehicle()) then
			ply:ExitVehicle();
		end
		GM:Log(EVENT_POLICEEVENT, "%s unarrested %s.", self.Owner:Name(), ply:Name());
		gamemode.Call("PlayerUnarrest", self.Owner, ply);
		ply:UnArrest();
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
