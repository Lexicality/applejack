--[[
	~ Baton ~ Shared ~
	~ Applejack ~
--]]

-- Define some shared variables.
SWEP.Author	= "Lexi";
SWEP.Instructions = "Primary Fire: Knock Out. Use+Primary Fire: Damage\nSecondary Fire: Arrest/breach door.";
SWEP.Purpose = "General Purpous Electrical Baton";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_stunstick.mdl";
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "stunstick";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
  
-- Set the primary fire settings.
SWEP.Primary.Delay = 0.75;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

-- Set the secondary fire settings.
SWEP.Secondary.Delay = 0.75;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "";

-- Set the iron sight positions (pointless here).
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
end
-- Do the SWEP's hit effects. <-- Credits to kuromeku
function SWEP:DoHitEffects(sound)
	local trace = self.Owner:GetEyeTrace();
	-- Check if the trace hit or it hit the world.
	if ( ( (trace.Hit or trace.HitWorld) and self.Owner:GetPos():Distance(trace.HitPos) <= 96 ) ) then
		if ( ValidEntity(trace.Entity) and ( trace.Entity:IsPlayer() or trace.Entity:IsNPC() ) ) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			self.Weapon:EmitSound(sound or "weapons/stunstick/stunstick_fleshhit"..math.random(1, 2)..".wav");
		elseif ( ValidEntity(trace.Entity)
		and ValidEntity( trace.Entity:GetNetworkedEntity("player") ) ) then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			self.Weapon:EmitSound(sound or "weapons/stunstick/stunstick_fleshhit"..math.random(1, 2)..".wav");
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			self.Weapon:EmitSound(sound or "weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav");
		end
		
		-- Create new effect data.
		local effectData = EffectData();
		
		-- Set some information about the effect.
		effectData:SetStart(trace.HitPos);
		effectData:SetOrigin(trace.HitPos)
		effectData:SetScale(32);
		
		-- Create the effect.
		util.Effect("StunstickImpact", effectData);
	else
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
		self.Weapon:EmitSound("weapons/stunstick/stunstick_swing1.wav");
	end
end

function SWEP:OnAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:DoHitEffects()
end
