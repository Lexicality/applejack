--
-- ~ AK47 SWEP ~
-- ~ Applejack ~
--
AddCSLuaFile();
if (CLIENT) then
	SWEP.DrawAmmo = true;
	SWEP.DrawCrosshair = false;
	SWEP.ViewModelFlip = true;
	SWEP.CSMuzzleFlashes = true;
	SWEP.CustomCrosshair = false -- = true;
	SWEP.Slot = 3;
	SWEP.SlotPos = 1;
	SWEP.IconLetter = "b";
	SWEP.DrawWeaponInfoBox = true;
	killicon.AddFont(
		"cider_ak47", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255)
	)
end

-- Set the base and category.
SWEP.Base = "rg_base";
SWEP.Category = "Cider";

-- Set some shared information.
SWEP.PrintName = "AK47";
SWEP.Author = "kuromeku";
SWEP.Purpose = "A very powerful rifle which is great at long range.";
SWEP.Instructions =
	"Primary Fire: Shoot.\nUse + Secondary Fire: Change the fire mode.";
SWEP.Spawnable = true;
SWEP.AdminOnly = true;
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
SWEP.Size = TYPE_LARGE
SWEP.TypeName = "assault rifle"
SWEP.HoldType = "ar2";
SWEP.FiresUnderwater = false;
SWEP.HasLaser = false;
SWEP.HasSilencer = false;
SWEP.CanPenetrate = true;
SWEP.CanPenetrateWorld = true;
SWEP.BulletTracer = 1;

-- Set some information for the primary fire.
SWEP.Primary.Sound = Sound("Weapon_AK47.Single");
SWEP.Primary.Damage = 12.5;
SWEP.Primary.NumShots = 1;
SWEP.Primary.ClipSize = 25;
SWEP.Primary.DefaultClip = 25;
SWEP.Primary.Ammo = "smg1";

-- Set some information for the secondary fire.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

-- Set some information about the recoil and spray.
SWEP.RecoverTime = 0.75;
SWEP.MinSpread = 0.01;
SWEP.MaxSpread = 0.08;
SWEP.DeltaSpread = 0.01;
SWEP.MinRecoil = 1;
SWEP.MaxRecoil = 5;
SWEP.DeltaRecoil = 1;
SWEP.MinSpray = 0;
SWEP.MaxSpray = 2;
SWEP.DeltaSpray = 0.25;

-- Set some information about the iron sights.
SWEP.IronSightsPos = Vector(6.1353, -3.04, 2.2783)
SWEP.IronSightsAng = Vector(2.4374, -0.0488, 0)

SWEP.IronSightZoom = 1;
SWEP.UseScope = false;
SWEP.ScopeScale = 0.4;
SWEP.ScopeZooms = {4, 8};
SWEP.DrawSniperSights = false;
SWEP.DrawRifleSights = false;

-- Set some information about the model and visual effects.
SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl";
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl";
SWEP.MuzzleEffect = "rg_muzzle_highcal";
SWEP.ShellEffect = "rg_shelleject_rifle";
SWEP.MuzzleAttachment = "1";
SWEP.ShellEjectAttachment = "2";

-- Set some modifier information.
SWEP.CrouchModifier = 0.7;
SWEP.IronSightModifier = 0.4;
SWEP.RunModifier = 1.5;
SWEP.JumpModifier = 2;

-- Set some information about the available fire modes and RPM.
SWEP.AvailableFireModes = {"Auto", "Semi"};
SWEP.AutoRPM = 600;
SWEP.SemiRPM = 500;
