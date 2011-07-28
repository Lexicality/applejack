--[[
	~ Baton ~ Clientside ~
	~ Applejack ~
--]]
include("shared.lua");

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


-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self:OnAttack();
end

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self:OnAttack();
end
