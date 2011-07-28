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
-- Bitchin smart lookin instructions o/
local title_color = "<color=230,230,230,255>"
local text_color = "<color=150,150,150,255>"
local end_color = "</color>"
SWEP.Instructions =
    end_color..title_color.."Primary Fire:\t"..			end_color..text_color.." Punch / Throw\n"..
    end_color..title_color.."Secondary Fire:\t"..		end_color..text_color.." Knock / Pick Up / Drop\n"..
    end_color..title_color.."Sprint+Primary Fire:\t"..	end_color..text_color.." Lock\n"..
    end_color..title_color.."Sprint+Secondary Fire:\t"..end_color..text_color.." Unlock";
SWEP.Purpose = "Picking stuff up, knocking on doors and punching people.";


function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "CSSelectIcons", x + 0.59*wide, y + tall*0.2, Color(255, 220, 0, 255), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo(x + wide + 20, y + tall*0.95, alpha)
end
killicon.AddFont( "cider_hands", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

local function wtfboom(_, tr, _)
    local ed = EffectData();
    ed:SetStart (tr.HitPos);
    ed:SetOrigin(tr.HitPos);
    ed:SetScale (1);
    util.Effect("Explosion", ed);
end

--- Swep code.

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self.Primary.NextSwitch = CurTime() 
	self:SetWeaponHoldType("normal");
end

function SWEP:PrimaryAttack()
    local ply = self.Owner;
    local keys = ply:KeyDown(IN_SPEED);
    -- If the player is exhausted, they can only use their keys.
    if (not keys and ply:GetNWBool("Exhausted")) then
        return;
    end
	-- Punch and woosh.
	self:EmitSound("npc/vort/claw_swing2.wav");
	self:SendWeaponAnim(ACT_VM_HITCENTER);
    -- Slow down the punches.
	self:SetNextPrimaryFire(CurTime() + self.Primary.Refire);
    -- Check if we're holding something, and don't do the punching code if we are
    if (self:GetDTBool(0)) then
        return;
    end
    -- Get where we're punching.
    local tr = ply:GetEyeTraceNoCursor();
    if (not (tr.Hit or tr.HitWorld) or tr.StartPos:Distance(tr.HitPos) > 128) then
        return;
    end
    -- Are we using keys?
    if (keys) then
        -- As the client we don't do much, but we do need to lower the refire time.
        self:SetNextPrimaryFire(CurTime() + 0.75);
        self:SetNextSecondaryFire(CurTime() + 0.75);
        -- Ok, job done, let's get out of here.
        return;
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
    if (not tr.HitWorld and self:GetDTBool(1)) then
        bullet.Callback = wtfboom;
    end
    ply:FireBullets(bullet);
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
    local ply = self.Owner;
    local tr = ply:GetEyeTraceNoCursor();
    if (tr.HitWorld or not tr.Hit or tr.StartPos:Distance(tr.HitPos) > 128) then
        return;
    end
    -- Implicitly valid.
    local ent = tr.Entity;
    if (ent:IsDoor()) then
        -- Knock
        self:SendWeaponAnim(ACT_VM_HITCENTER);
        self:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
        self:SetNextSecondaryFire(CurTime() + 0.25);
    elseif (ply:KeyDown(IN_SPEED)) then
        -- Attempted to unlock
        self:SetNextPrimaryFire(CurTime() + 0.75);
        self:SetNextSecondaryFire(CurTime() + 0.75);
        self:SendWeaponAnim(ACT_VM_HITCENTER);
    end
end
