--[[
	~ Hands Swep ~ Serverside ~
	~ Applejack ~
--]]
includecs("shared.lua");
AddCSLuaFile("cl_init.lua");

local stamina;
function SWEP:Initialize()
	self.Primary.NextSwitch = CurTime()
	self:SetWeaponHoldType("normal");
	stamina = GM:GetPlugin("stamina");
end

function SWEP:PrimaryAttack()
	local ply = self.Owner;
	local keys = ply:KeyDown(IN_SPEED);
	if (not (keys or self:GetDTBool(0)) and ply:GetNWBool("Exhausted")) then
		return;
	end
	-- Punch and woosh.
	self:EmitSound("npc/vort/claw_swing2.wav");
	self:SendWeaponAnim(ACT_VM_HITCENTER);
	-- Slow down the punches.
	self:SetNextPrimaryFire(CurTime() + self.Primary.Refire);

	-- See where we're punching
	local tr = ply:GetEyeTraceNoCursor();
	if (not (tr.Hit or tr.HitWorld) or tr.StartPos:Distance(tr.HitPos) > 40) then
		return;
	end
	local ent = tr.Entity;

	-- Check for keys
	if (keys) then
		self:SetNextPrimaryFire(CurTime() + 0.75);
		self:SetNextSecondaryFire(CurTime() + 0.75);
		-- If we hit the world or
		if (tr.HitWorld or not ent:IsOwnable() or ent._Jammed) then
			return;
		elseif (not ent:HasAccess(ply)) then
			ply:Notify("You do not have access to that lock!", 1);
			return;
		end
		-- Lock
		ent:Lock();
		ent:EmitSound("doors/door_latch3.wav");
		return;
	end
	-- Stamina
	if (stamina and not self:GetDTBool(0)) then
		self.Owner._Stamina = math.Clamp(self.Owner._Stamina - 20,0,100)
	end
	-- Smack
	self:EmitSound("weapons/crossbow/hitbod2.wav");
	-- Fire a bullet for impact effects
	local bullet = {
		Num = 1;
		Src = tr.StartPos;
		Dir = tr.Normal;
		Spread = Vector(0,0,0);
		Tracer = 0;
		Force = 0;
		Damage = 0;
	}
	-- Check if super punch mode is on
	if (not tr.HitWorld and self:GetDTBool(0)) then
		bullet.Callback = wtfboom;
	end
	ply:FireBullets(bullet);
	-- Check what we hit
	if (tr.HitWorld) then
		return;
	end
	-- We have hit an entity. Beat it's pasty ass into the ground
	-- Don't let people punch each other to death
	if ((ent._Player or ent:IsPlayer()) and not self:GetDTBool(0) and ent:Health() <= 15) then
		-- Re stun (OH WAIT STUN ISN'T PROGRESSIVE EVEN THOUGH IT SHOULD BE >:c)
		local pl = ent;
		if (IsValid(ent._Player)) then
			pl = ent._Player;
		end
		pl._Stunned = true;
		if (not pl:KnockedOut()) then
			pl:KnockOut(GM.Config["Knock Out Time"] / 2);
			GM:Log(EVENT_EVENT, "%s knocked out %s with a punch.", ply:Name(), pl:Name());
		end
		return;
	end
	-- Use CDamageInfo for superior damage control.
	local dmg = DamageInfo();
	dmg:SetAttacker(ply);
	dmg:SetInflictor(self);
	dmg:SetDamage(self.Primary.Damage);
	local phys = ent:GetPhysicsObject();
	if (IsValid(phys) and phys:IsMoveable()) then
		dmg:SetDamageForce(tr.Normal * self.Primary.PunchAcceleration * phys:GetMass());
	end
	dmg:SetDamagePosition(tr.HitPos);
	if (self:GetDTBool(0)) then -- super
		dmg:SetDamageType(DMG_BLAST);
	else
		dmg:SetDamageType(DMG_CLUB);
	end
	-- TAKE THAT!
	ent:TakeDamageInfo(dmg);
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.25);
	local ply = self.Owner;
	local tr = ply:GetEyeTraceNoCursor();
	if (tr.HitWorld or not tr.Hit or tr.StartPos:Distance(tr.HitPos) > 128) then
		return;
	end
	-- Implicitly valid.
	local ent = tr.Entity;
	if (ply:KeyDown(IN_SPEED)) then
		-- Attempted to unlock
		self:SetNextPrimaryFire(CurTime() + 0.75);
		self:SetNextSecondaryFire(CurTime() + 0.75);
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		if (tr.HitWorld or not ent:IsOwnable() or ent._Jammed) then
			return;
		elseif (not ent:HasAccess(ply)) then
			ply:Notify("You do not have access to that lock!", 1);
			return;
		end
		-- Lock
		ent:UnLock();
		ent:EmitSound("doors/door_latch3.wav");
	elseif (ent:IsDoor()) then
		-- Knock
		self:SendWeaponAnim(ACT_VM_HITCENTER);
		self:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
		-- Cheats!
		if (self:GetDTBool(0) and ply:IsSuperAdmin()) then
			GM:OpenDoor(ent, 0);
		end
	else
		self:PickUp(ent, tr);
	end
end


function SWEP:Reload()
	if (not (self.Owner:IsAdmin() and self.Owner:KeyDown(IN_SPEED)) or self.Primary.NextSwitch > CurTime()) then
		return false;
	elseif (self:GetDTBool(0)) then
		self.Primary.PunchAcceleration = 100
		self.Primary.ThrowAcceleration = 200
		self.Primary.Damage = 1.5
		self.Primary.Refire = 1
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode disabled")
		self:SetDTBool(0, false);
	else
		self.Primary.PunchAcceleration = 500
		self.Primary.ThrowAcceleration = 1000
		self.Primary.Damage = 200
		self.Primary.Refire = 0
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode enabled")
		self:SetDTBool(0, true);
	end
	self.Primary.NextSwitch = CurTime() + 1
end

function SWEP:PickUp(ent, tr)
	if (ent:IsPlayerHolding()) then
		self.Owner:Notify("Someone else is already holding that!", 1);
		return;
	end
	local res, err = self.Owner:CanPickupObject(ent, 60, 200)
	if (not res) then
		self.Owner:Notify(err);
		return;
	end
	-- TODO: What happens if you pickup a ragdoll?
	--       If it doesn't work, then make a small prop, weld that to the physbone and then pickup that.
	self.PickupAttempt = ent;
	--self.Owner:PickupObject(ent);
end

function SWEP:Think()
	if (not self.PickupAttempt) then
		return;
	elseif (self.Owner:KeyDown(IN_ATTACK2)) then
		-- While the guy holds the right mouse button down, they'll drop the object instantly.
		return;
	elseif (IsValid(self.PickupAttempt)) then
		self.Owner:PickupObject(self.PickupAttempt);
	end
	self.PickupAttempt = nil;
end

