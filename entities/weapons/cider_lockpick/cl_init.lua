--[[
	~ Lockpick SWep ~ Clientside ~
	~ Applejack ~
--]]
include("shared.lua");
SWEP.PrintName = "Lockpick";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo = false;
SWEP.IconLetter = "c"
SWEP.DrawCrosshair = true;

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.IconLetter, "TitleFont2", x + 0.5*wide, y --[[+ tall*0.2]], Color(255, 220, 0, 255), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo(x + wide + 20, y + tall*0.95, alpha)
end

usermessage.Hook("dosnd", function(m)
	local wpn = LocalPlayer():GetActiveWeapon()
	if (IsValid(wpn) and wpn:GetClass() == "cider_lockpick") then
		wpn:DoSound(m:ReadChar(), m:ReadChar());
	end
end)

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	-- Set the animation of the owner to one of them attacking.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	local tr = self.Owner:GetEyeTrace();
	local owner = self.Owner;
	if (owner:GetShootPos():Distance(tr.HitPos) > 128) then
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
		return;
	end
	self:SendWeaponAnim(ACT_VM_HITCENTER);
end