--[[
	~ Hands Swep ~ Clientside ~
	~ Applejack ~
--]]

include("shared.lua");

SWEP.PrintName = "Hands";
SWEP.Slot = 1;
SWEP.SlotPos = 1;
SWEP.DrawAmmo = false;
SWEP.IconLetter = "H"
SWEP.DrawCrosshair = false;

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + 0.59*wide, y + tall*0.2, Color(255, 220, 0, 255), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo(x + wide + 20, y + tall*0.95, alpha)
end
killicon.AddFont( "cider_hands", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

function SWEP:Initialize()
	self.Primary.NextSwitch = CurTime() 
	self:SetWeaponHoldType("normal");
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Refire);
	if not self.Owner:KeyDown(IN_SPEED) and self.Owner:GetNWBool"Exausted" then
		return
	end
	-- Set the animation of the weapon and play the sound.
	self:EmitSound("npc/vort/claw_swing2.wav");
	self:SendWeaponAnim(ACT_VM_HITCENTER);
	-- Get an eye trace from the owner.
	local trace = self.Owner:GetEyeTrace();

	
	-- Check the hit position of the trace to see if it's close to us.
	if self.Owner:GetPos():Distance(trace.HitPos) <= 128 and ValidEntity(trace.Entity) then
		if self.Owner:KeyDown(IN_SPEED) then
			self:SetNextPrimaryFire(CurTime() + 0.75);
			self:SetNextSecondaryFire(CurTime() + 0.75);
		elseif (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
			if not (not self.Primary.Super and trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 15) then
				local bullet = {}
				
				-- Set some information for the bullet.
				bullet.Num = 1;
				bullet.Src = self.Owner:GetShootPos();
				bullet.Dir = self.Owner:GetAimVector();
				bullet.Spread = Vector(0, 0, 0);
				bullet.Tracer = 0;
				bullet.Force = self.Primary.Force;
				bullet.Damage = self.Primary.Damage;
				if self.Primary.Super then
					bullet.Callback	= function ( attacker, tr, dmginfo ) 
						if  !ValidEntity(tr.Entity) then return end
						local effectData = EffectData();
						-- Set the information for the effect.
						effectData:SetStart( tr.HitPos );
						effectData:SetOrigin( tr.HitPos );
						effectData:SetScale(1);
						
						-- Create the effect from the data.
						util.Effect("Explosion", effectData);
					end
				end
				-- Fire bullets from the owner which will hit the trace entity.
				self.Owner:FireBullets(bullet);
			end
		end
		
		-- Check if the trace hit an entity or the world.
		if (trace.Hit or trace.HitWorld) then self:EmitSound("weapons/crossbow/hitbod2.wav"); end
	end
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.25);
	
	-- Get a trace from the owner's eyes.
	local trace = self.Owner:GetEyeTrace();
	-- Check to see if the trace entity is valid and that it's a door.
	if ValidEntity(trace.Entity) and self.Owner:GetPos():Distance(trace.HitPos) <= 128 then
		local ent = trace.Entity
		--self:EmitSound("npc/vort/claw_swing2.wav");
		if ent:IsOwnable() then
			if self.Owner:KeyDown(IN_SPEED) then
				self:SetNextPrimaryFire(CurTime() + 0.75);
				self:SetNextSecondaryFire(CurTime() + 0.75);
				self:SendWeaponAnim(ACT_VM_HITCENTER);
			elseif ent:IsDoor() then
				self:SendWeaponAnim(ACT_VM_HITCENTER);
				self:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
			end
		end
	end
end