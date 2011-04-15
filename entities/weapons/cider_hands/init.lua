--[[
	~ Hands Swep ~ Serverside ~
	~ Applejack ~
--]]
includecs("shared.lua");
AddCSLuaFile("cl_init.lua");

SWEP.HeldEnt = NULL

local stamina;
function SWEP:Initialize()
	self.Primary.NextSwitch = CurTime() 
	self:SetWeaponHoldType("normal");
	stamina = GM:GetPlugin("stamina");
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Refire);
	if ValidEntity(self.HeldEnt)then
		self:DropObject(self.Primary.ThrowAcceleration)
		return
	end
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
		if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") and not self.Owner:KeyDown(IN_SPEED) then
			if (not self.Primary.Super and
			trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 15) then
				GM:Log(EVENT_EVENT,"%s knocked out %s with a punch.",self.Owner:Name(),trace.Entity:Name());
				trace.Entity._Stunned = true
				trace.Entity:KnockOut(GM.Config["Knock Out Time"] / 2);
			else
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
		else
			--if  then--ent:IsDoor(); or ent:IsVehicle() then
			if self.Owner:KeyDown(IN_SPEED) then
				self:SetNextPrimaryFire(CurTime() + 0.75);
				self:SetNextSecondaryFire(CurTime() + 0.75);
				--Keys!
				if trace.Entity:IsOwned() and not trace.Entity._Jammed  then
					if (trace.Entity:HasAccess(self.Owner)) then
						trace.Entity:Lock()
						trace.Entity:EmitSound("doors/door_latch3.wav");
					else
						self.Owner:Notify("You do not have access to that!",1)
					end
				end
				return
			else
				local phys = trace.Entity:GetPhysicsObject()
				if ValidEntity(phys) and phys:IsMoveable() then
					trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * self.Primary.PunchAcceleration * phys:GetMass(), trace.HitPos);
					if self.Primary.Super then
						trace.Entity:TakeDamage(self.Primary.Damage,self.Owner)
					end
				end
			end
		end
		if (trace.Hit or trace.HitWorld) then
			self:EmitSound("weapons/crossbow/hitbod2.wav");
		end
	end
	if not self.Owner:KeyDown(IN_SPEED) and stamina and not self.Primary.Super then
		self.Owner._Stamina = math.Clamp(self.Owner._Stamina - 20,0,100)
	end
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.25);
	if ValidEntity(self.HeldEnt)then
		self:DropObject()
		return
	end
	
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
				if not trace.Entity._Jammed then
					if ent:HasAccess(self.Owner) then
						ent:UnLock()
						ent:EmitSound("doors/door_latch3.wav");
					else
						self.Owner:Notify("You do not have access to that!",1)
					end
				end
				return
			elseif ent:IsDoor() then
				self:SendWeaponAnim(ACT_VM_HITCENTER);
				self:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
				if self.Primary.Super and self.Owner:IsSuperAdmin() then
					GM:OpenDoor(ent, 0)
				end
				return
			end
		end
		self:PickUp(ent,trace)
	end
end







-- TODO: Make this use kuro's method.
function SWEP:Think()
	if not self.HeldEnt then return end
	if !ValidEntity(self.HeldEnt) then
		if ValidEntity(self.EntWeld) then self.EntWeld:Remove() end
		self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
		self:Speed()
		return
	elseif !ValidEntity(self.EntWeld) then
		self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
		self:Speed()
		return
	end
	if !self.HeldEnt:IsInWorld() then
		self.HeldEnt:SetPos(self.Owner:GetShootPos())
		self:DropObject()
		return
	end
	if self.NoPos then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	self.HeldEnt:SetPos(pos+(ang*60))
	self.HeldEnt:SetAngles(Angle(self.EntAngles.p,(self.Owner:GetAngles().y-self.OwnerAngles.y)+self.EntAngles.y,self.EntAngles.r))
end
function SWEP:Speed(down)
	if down then
		self.Owner:Incapacitate()
	else
		self.Owner:Recapacitate()
	end
end

function SWEP:Holster()
	self:DropObject()
	self.Primary.NextSwitch = CurTime() + 1
	return true
end

function SWEP:PickUp(ent,trace)
	if ent.held then return end
	if (constraint.HasConstraints(ent) or ent:IsVehicle()) then
		return false
	end
	local pent = ent:GetPhysicsObject( )
	if !ValidEntity(pent) then return end
	if pent:GetMass() > 60 or not pent:IsMoveable() then
		return
	end
	if ent:GetClass() == "prop_ragdoll" then
		return false
	else
		ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
		local EntWeld = {}
		EntWeld.ent = ent
		function EntWeld:IsValid() return ValidEntity(self.ent) end
		function EntWeld:Remove()
			if ValidEntity(self.ent) then self.ent:SetCollisionGroup( COLLISION_GROUP_NONE ) end
		end
		self.NoPos = false
		self.EntWeld = EntWeld
	end
	--print(self.EntWeld)
--	print("k, pickin up")
	self.Owner._HoldingEnt = true
	self.HeldEnt = ent
	self.HeldEnt.held = true
	self.EntAngles = ent:GetAngles()
	self.OwnerAngles = self.Owner:GetAngles()
	self:Speed(true)
end

function SWEP:DropObject(acceleration)
	acceleration = acceleration or 0.1
	if !ValidEntity(self.HeldEnt) then return true end
	if ValidEntity(self.EntWeld) then self.EntWeld:Remove() end
	local pent = self.HeldEnt:GetPhysicsObject( )
	if pent:IsValid() then
		pent:ApplyForceCenter(self.Owner:GetAimVector() * pent:GetMass() * acceleration)
		--print(pent:GetMass() , acceleration,pent:GetMass() * acceleration)
	end
	self.Owner._HoldingEnt, self.HeldEnt.held, self.HeldEnt, self.EntWeld, self.EntAngles, self.OwnerAngles = nil
	self:Speed()
end

function SWEP:OnRemove()
	self:DropObject()
	return true
end