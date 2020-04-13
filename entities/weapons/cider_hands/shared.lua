--
-- "shared.lua"
-- ~ Applejack ~
--

-- Define some shared variables.
SWEP.Author	= "Lexi";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_fists.mdl";
SWEP.WorldModel = "models/weapons/w_fists.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "admire";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;

-- Set the primary fire settings.
SWEP.Primary.Damage = 1.5;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";
SWEP.Primary.Force = 5;
SWEP.Primary.PunchAcceleration = 100
SWEP.Primary.ThrowAcceleration = 200
SWEP.Primary.Super = false;
SWEP.Primary.Refire = 1

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "";

-- Set the iron sight positions (pointless here).
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
