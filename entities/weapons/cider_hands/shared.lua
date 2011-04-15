--[[
	~ Hands SWEP ~ Shared ~
	~ Applejack ~
--]]

-- Define some shared variables.
SWEP.Author	= "Lexi";
-- Bitchin smart lookin instructions o/
local title_color = "<color=230,230,230,255>"
local text_color = "<color=150,150,150,255>"
local end_color = "</color>"
SWEP.Instructions =	end_color..title_color.."Primary Fire:\t"..			end_color..text_color.." Punch / Throw\n"..
					end_color..title_color.."Secondary Fire:\t"..			end_color..text_color.." Knock / Pick Up / Drop\n"..
					end_color..title_color.."Sprint+Primary Fire:\t"..	end_color..text_color.." Lock\n"..
					end_color..title_color.."Sprint+Secondary Fire:\t"..	end_color..text_color.." Unlock";
SWEP.Purpose = "Picking stuff up, knocking on doors and punching people.";

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

function SWEP:Reload()
	if self.Primary.NextSwitch > CurTime() then return false end
	if self.Owner:IsAdmin() and self.Owner:KeyDown(IN_SPEED) then
		if self.Primary.Super then
			self.Primary.PunchAcceleration = 100
			self.Primary.ThrowAcceleration = 200
			self.Primary.Damage = 1.5
			self.Primary.Super = false
			self.Primary.Refire = 1
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode disabled")
		else
			self.Primary.PunchAcceleration = 500
			self.Primary.ThrowAcceleration = 1000
			self.Primary.Damage = 200
			self.Primary.Super = true
			self.Primary.Refire = 0
			self.Owner:PrintMessage(HUD_PRINTCENTER, "Super mode enabled")
		end
		self.Primary.NextSwitch = CurTime() + 1
	end
end