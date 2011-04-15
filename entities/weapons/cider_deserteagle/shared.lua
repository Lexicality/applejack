--[[
Name: "shared.lua".
	~ Applejack ~
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
else
	SWEP.DrawAmmo = true;
	SWEP.DrawCrosshair = false;
	SWEP.ViewModelFlip = true;
	SWEP.CSMuzzleFlashes = true;
	SWEP.CustomCrosshair = false -- = true;
	SWEP.Slot = 1;
	SWEP.SlotPos = 1;
	SWEP.IconLetter = "f";
	SWEP.DrawWeaponInfoBox = true;
	killicon.AddFont( "cider_deserteagle", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

-- Set the base and category.
SWEP.Base = "rg_base";
SWEP.Category = "Cider";

-- Set some shared information.
SWEP.PrintName = "Desert Eagle";
SWEP.Author = "kuromeku";
SWEP.Purpose = "A powerful pistol with a lot of punch.";
SWEP.Instructions = "Primary Fire: Shoot.";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
SWEP.Size = TYPE_SMALL
SWEP.TypeName = "pistol"
SWEP.HoldType = "pistol";
SWEP.FiresUnderwater = false;
SWEP.HasSilencer = false;
SWEP.HasLaser = false;
SWEP.CanPenetrate = true;
SWEP.CanPenetrateWorld = true;
SWEP.BulletTracer = 1;

-- Set some information for the primary fire.
SWEP.Primary.Sound = Sound("Weapon_Deagle.Single");
SWEP.Primary.Damage = 200;
SWEP.Primary.NumShots = 1;
SWEP.Primary.ClipSize = 8;
SWEP.Primary.DefaultClip = 8;
SWEP.Primary.Ammo = "pistol";

-- Set some information for the secondary fire.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

-- Set some information about the recoil and spray.
SWEP.RecoverTime = 0.7;
SWEP.MinSpread = 0.02;
SWEP.MaxSpread = 0.05;
SWEP.DeltaSpread = 0.02;
SWEP.MinRecoil = 10;
SWEP.MaxRecoil = 20;
SWEP.DeltaRecoil = 1;
SWEP.MinSpray = 0;
SWEP.MaxSpray = 2;
SWEP.DeltaSpray = 0.25;

-- Set some information about the iron sights.
--[[ SWEP.IronSightsPos = Vector(5.1588, -6.4072, 2.3894);
SWEP.IronSightsAng = Vector(2.0239, -0.0813, -0.1968);
 ]]
SWEP.IronSightsPos = Vector (5.1444, -0.403, 2.5673)
SWEP.IronSightsAng = Vector (0.6577, -0.0624, 0)

SWEP.IronSightZoom = 1;
SWEP.UseScope = false;
SWEP.ScopeScale = 0.4;
SWEP.ScopeZooms = {4, 8};
SWEP.DrawSniperSights = false;
SWEP.DrawRifleSights = false;

-- Set some information about the model and visual effects.
SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl";
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl";
SWEP.MuzzleEffect = "rg_muzzle_pistol";
SWEP.ShellEffect = "rg_shelleject";
SWEP.MuzzleAttachment = "1";
SWEP.ShellEjectAttachment = "2";

-- Set some modifier information.
SWEP.CrouchModifier = 0.7;
SWEP.IronSightModifier = 0.4;
SWEP.RunModifier = 1.5;
SWEP.JumpModifier = 2;

-- Set some information about the available fire modes and RPM.
SWEP.AvailableFireModes = {"Semi"};
SWEP.SemiRPM = 300;