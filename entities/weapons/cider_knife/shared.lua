--[[
Name: "shared.lua".
	~ Applejack ~
--]]

if (SERVER) then AddCSLuaFile("shared.lua"); end

-- Set the icon letter of the SWEP.
SWEP.IconLetter	= "j";

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.Slot = 3;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
	SWEP.DrawWeaponInfoBox = true;
	
	-- Add the kill icon font.
	killicon.AddFont("cider_knife", "CSKillIcons", SWEP.IconLetter, Color(255, 245, 40, 255));
end

-- Called when the weapon selection should be drawn.
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 245, 10, 255), 1);
--	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2 + math.Rand(-4, 4), y + tall * 0.2 + math.Rand(-14, 14), Color(255, 210, 0, math.Rand(10, 120)), 1);
--	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2 + math.Rand(-4, 4), y + tall * 0.2 + math.Rand(-9, 9), Color(255, 210, 0, math.Rand(10, 120)), 1);
end

-- Set some shared information.
SWEP.Author = "kuromeku";
SWEP.Instructions = "Primary Fire: Stab.";
SWEP.Contact = "http://kuromeku.com/forums/";
SWEP.Purpose = "A compact knife that does greater damage from behind.";
SWEP.Category = "Cider";
SWEP.PrintName = "Knife";
SWEP.ViewModelFOV = 60;
SWEP.ViewModelFlip = false;
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
SWEP.NextAttack = 0;
SWEP.ViewModel = "models/weapons/v_knife_t.mdl";
SWEP.WorldModel = "models/weapons/w_knife_t.mdl";
  
-- Set some information for the primary fire.
SWEP.Primary.Delay = 0.75;
SWEP.Primary.Recoil = 0;
SWEP.Primary.Damage	= 10;
SWEP.Primary.NumShots = 1;
SWEP.Primary.Cone = 0;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.NextAttack = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "none";

-- Set some information for the secondary fire.
SWEP.Secondary.Delay = 0.75;
SWEP.Secondary.Recoil = 0;
SWEP.Secondary.Damage = 0;
SWEP.Secondary.NumShots	= 1;
SWEP.Secondary.Cone	= 0;
SWEP.Secondary.ClipSize	= -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = true;
SWEP.Secondary.Ammo = "none";

-- Precache the knife sounds.
util.PrecacheSound("weapons/knife/knife_deploy1.wav");
util.PrecacheSound("weapons/knife/knife_hitwall1.wav");
util.PrecacheSound("weapons/knife/knife_hit1.wav");
util.PrecacheSound("weapons/knife/knife_hit2.wav");
util.PrecacheSound("weapons/knife/knife_hit3.wav");
util.PrecacheSound("weapons/knife/knife_hit4.wav");
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav");

-- Called when the SWEP initializes.
function SWEP:Initialize()
	if (SERVER) then self:SetWeaponHoldType("melee"); end
	
	-- A table to store the knife sounds.
	self.hitSounds = { Sound("weapons/knife/knife_hitwall1.wav") };
	self.fleshSounds = {
		Sound("weapons/knife/knife_hit1.wav"),
		Sound("weapons/knife/knife_hit2.wav"),
		Sound("weapons/knife/knife_hit3.wav"),
		Sound("weapons/knife/knife_hit4.wav")
	};
end

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self.Owner:EmitSound("weapons/knife/knife_deploy1.wav");
	
	-- Return true to override the deploy function.
	return true;
end

-- The primary attack function.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	
	-- Define some variables such as the trace and damage of the SWEP.
	local trace = self.Owner:GetEyeTrace();
	local damage = self.Primary.Damage;
	
	-- Check if we're close to our target.
	if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		shoot = true;
		
		-- Check if we hit a valid entity.
		if ( IsValid(trace.Entity) ) then
			if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
				self.Owner:EmitSound( self.fleshSounds[ math.random(1, #self.fleshSounds) ] );
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
				
				-- Check if we're running on the server.
				if (SERVER) then
					if (trace.Entity:GetClass() != "prop_ragdoll") then
						local aimVectorOwner = self.Owner:GetAimVector();
						
						-- Check if we hit a player.
						if ( trace.Entity:IsPlayer() ) then
							if (trace.Entity:Tied()) then
								self.Owner:Emote("skillfully slices through the ropes on " .. trace.Entity:Name() .. "'s wrists.");
								trace.Entity:UnTie();
								trace.Entity:Emote("shakes the remains of the rope from " .. trace.Entity._GenderWord .. " wrists and rubs them");
								return
							elseif (trace.Entity:GetAimVector():DotProduct(aimVectorOwner) > 0.5) then damage = damage * 2; end
						elseif ( trace.Entity:IsNPC() ) then
							local aimVectorNPC = trace.Entity:GetAimVector();
							
							-- Check the dot product of the NPC's aim vector and the owner's aim vector.
							if (aimVectorNPC:DotProduct(aimVectorOwner) > 0) then
								damage = damage * 5;
							else
								damage = damage * 2;
							end
						end
					end
				end
			elseif (trace.Entity:GetClass() == "prop_physics") or trace.Entity:IsDoor() then
				self.Owner:EmitSound( self.hitSounds[ math.random(1, #self.hitSounds) ] );
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
				
				-- Draw a decal at the hit position.
				util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
				
				-- We no longer want to shoot a bullet.
				shoot = false;
			else
				self.Owner:EmitSound( self.hitSounds[ math.random(1, #self.hitSounds) ] );
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
				
				-- Draw a decal at the hit position.
				util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			end
		elseif (trace.Hit) then
			self.Owner:EmitSound( self.hitSounds[ math.random(1, #self.hitSounds) ] );
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			
			-- Draw a decal at the hit position.
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			
			-- We no longer want to shoot a bullet.
			shoot = false;
		else
			self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER);
		end
		
		-- Check if we should shoot a bullet.
		if (shoot) then
			local bullet = {}
			
			-- Set some information for the bullet.
			bullet.Num = 1;
			bullet.Src = self.Owner:GetShootPos();
			bullet.Dir = self.Owner:GetAimVector();
			bullet.Spread = Vector(0, 0, 0);
			bullet.Tracer = 0;
			bullet.Force = 5;
			bullet.Damage = damage;
			
			-- Fire a bullet from the owner.
			self.Owner:FireBullets(bullet);
		elseif ( IsValid(trace.Entity) ) then
			if ( IsValid( trace.Entity:GetPhysicsObject() ) ) then
				trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 500, trace.HitPos);
			end
		end
	else
		self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER);
	end
	
	-- Set the animation for the owner so that it looks like he is attacking.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
end

-- The secondary attack function.
function SWEP:SecondaryAttack() end
