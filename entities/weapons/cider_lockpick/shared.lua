--
-- ~ Lockpick SWep ~
-- ~ Applejack ~
--
if (SERVER) then
	AddCSLuaFile("shared.lua");
else
	SWEP.PrintName = "Lockpick";
	SWEP.Slot = 3;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.IconLetter = "c"
	SWEP.DrawCrosshair = true;

	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		draw.SimpleText(
			self.IconLetter, "HL2WeaponIcons", x + 0.5 * wide, y --[[+ tall*0.2]] ,
			Color(255, 220, 0, 255), TEXT_ALIGN_CENTER
		)
		self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	end
end

-- Define some shared variables.
SWEP.Author = "Lexi";
SWEP.Instructions = "Primary Fire: Attempt to pick Lock.";
SWEP.Contact = "";
SWEP.Purpose = "Unlocking locked things";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_crowbar.mdl";
SWEP.WorldModel = "models/weapons/w_crowbar.mdl";

-- Set whether it's spawnable by players and by administrators.
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;

-- Set the primary fire settings.
SWEP.Primary.Delay = 0.75;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "";

local fiddlesounds = {
	-- Metal thump noises
	-- "physics/metal/metal_box_impact_bullet1.wav",
	-- "physics/metal/metal_box_impact_bullet2.wav",
	-- "physics/metal/metal_box_impact_bullet3.wav",
	-- "physics/metal/metal_computer_impact_bullet1.wav",
	-- "physics/metal/metal_computer_impact_bullet2.wav",
	-- "physics/metal/metal_computer_impact_bullet3.wav",
	-- "physics/metal/metal_computer_impact_hard1.wav",
	-- "physics/metal/metal_computer_impact_hard2.wav",
	-- "physics/metal/metal_computer_impact_hard3.wav",
	-- "physics/metal/metal_computer_impact_soft1.wav",
	-- "physics/metal/metal_computer_impact_soft2.wav",
	-- "physics/metal/metal_computer_impact_soft3.wav",
	-- "physics/metal/metal_sheet_impact_bullet2.wav",
	-- "physics/metal/metal_solid_impact_bullet1.wav",
	-- "physics/metal/metal_solid_impact_bullet2.wav",
	-- "physics/metal/metal_solid_impact_bullet3.wav",
	"physics/metal/weapon_footstep1.wav",
	"physics/metal/weapon_footstep2.wav",
	"physics/metal/weapon_impact_soft1.wav",
	"physics/metal/weapon_impact_soft2.wav",
	"physics/metal/weapon_impact_soft3.wav",
}

local unlocksounds = {
	-- "physics/metal/sawblade_stick1.wav",
	-- "physics/metal/sawblade_stick2.wav",
	-- "physics/metal/sawblade_stick3.wav",
	"physics/metal/weapon_impact_hard1.wav",
	"physics/metal/weapon_impact_hard2.wav",
}

local breaksounds = {"physics/plastic/plastic_box_break1.wav"}
local thumpsounds = {
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav",
	"physics/flesh/flesh_impact_bullet5.wav",
}

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
	-- if (SERVER) then
	-- 	 -- TODO: Find out if sounds are actually precached.
	-- 	for _,sound in pairs(fiddlesounds) do
	-- 		Sound(sound);
	-- 	end
	-- 	for _,sound in pairs(unlocksounds) do
	-- 		Sound(sound);
	-- 	end
	-- 	for _,sound in pairs(breaksounds) do
	-- 		Sound(sound);
	-- 	end
	-- 	for _,sound in pairs(thumpsounds) do
	-- 		Sound(sound);
	-- 	end
	-- end
end

-- Allows me to send the client sounds
function SWEP:DoSound(tabn, sn)
	local tab;
	if (tabn == 0) then
		tab = fiddlesounds;
	elseif (tabn == 1) then
		tab = unlocksounds;
	elseif (tabn == 2) then
		tab = breaksounds
	elseif (tabn == 3) then
		tab = thumpsounds;
	end
	if (not tab) then
		error("Invalid table specified: " .. tabn, 2);
	elseif (not sn) then
		sn = math.random(#tab);
	end
	if (SERVER and IsValid(self.Owner)) then
		umsg.Start("dosnd", self.Owner);
		umsg.Char(tabn);
		umsg.Char(sn);
		umsg.End();
	end
	self:EmitSound(tab[sn]);
end
