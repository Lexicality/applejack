--[[
	~ Baton ~ Shared ~
	~ Applejack ~
--]]

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Baton";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
	SWEP.IconLetter = "n";
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(self.IconLetter, "TitleFont2", x + 0.5*wide, y --[[+ tall*0.2]], Color(255, 220, 0, 255), TEXT_ALIGN_CENTER )
		--draw.SimpleTextOutlined(self.IconLetter, "TitleFont2", x + 0.5*wide, y --[[+ tall*0.2]], Color(255, 220, 0, 255), TEXT_ALIGN_CENTER,nil,1, Color(255, 220, 0, 5))
		self:PrintWeaponInfo(x + wide + 20, y + tall*0.95, alpha)
	end
	killicon.AddFont( "cider_baton", "Titlefont", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

-- Define some shared variables.
SWEP.Author	= "Lexi"; --Admitedly, mostly made up of kudo's parts.
SWEP.Instructions = "Primary Fire: Knock Out. Use+Primary Fire: Damage\nSecondary Fire: Arrest/breach door.";
--SWEP.Contact = "urmom@urhouse lol.";
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
		and ValidEntity( trace.Entity:GetNetworkedEntity("cydar_Player") ) ) then
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

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:DoHitEffects()
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:DoHitEffects()
end
