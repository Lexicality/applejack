--
-- ~ Base Weapon ~
-- ~ Applejack ~
--
include("item.lua");
ITEM.Weapon = true;
ITEM.NoVehicles = true;
local function conditional(ply, pos)
	return ply:IsValid() and ply:GetPos() == pos;
end
local function success(ply, _, self)
	if (not ply:IsValid()) then
		return
	end
	ply:Emote(
		MS.Config["Weapon Timers"]["Equip Message"]["Final"]:format(self.WeaponType)
	);
	ply._Equipping = false;
	ply._FreshWeapons[self.UniqueID] = true;
	ply:Give(self.UniqueID);
	ply:SelectWeapon(self.UniqueID);
	cider.inventory.update(ply, self.UniqueID, -1);
	if self.OnEquip then
		self:OnEquip(ply);
	end
end

local function failure(ply)
	if (not ply:IsValid()) then
		return
	end
	ply:Emote(MS.Config["Weapon Timers"]["Equip Message"]["Abort"]);
	ply._Equipping = false;
	SendUserMessage("MS Equippr FAIL", ply);
end

function ITEM:onUse(ply)
	if (ply:HasWeapon(self.UniqueID)) then
		ply:SelectWeapon(self.UniqueID);
		return false;
	end
	if (self.Ammo and not tobool(ply:GetAmmoCount(self.Ammo))) then
		ply:Notify("You don't have enough ammunition for this weapon!", 1);
		return false;
	end
	if (not (self.WeaponType and MS.Config[self.WeaponType])) then
		ply:Give(self.UniqueID);
		ply:SelectWeapon(self.UniqueID);
		return true;
	end
	if (ply._NextDeploy > CurTime()) then
		ply:Notify(
			"You must wait another " ..
				string.ToMinutesSeconds(ply._NextDeploy - CurTime()) ..
				" before equipping another weapon!", 1
		);
		return false;
	end
	ply._GunCounts[self.WeaponType] = ply._GunCounts[self.WeaponType] or 0;
	if (ply._GunCounts[self.WeaponType] >= MS.Config[self.WeaponType]) then
		ply:Notify("You have too many " .. self.WeaponType .. " weapons equipped!", 1);
		return false
	end
	ply._Equipping = true;
	local delay = MS.Config["Weapon Timers"]["equiptime"][self.WeaponType];
	umsg.Start("MS Equippr", ply)
	umsg.Short(delay);
	umsg.Bool(true);
	umsg.End();
	timer.Conditional(
		ply:UniqueID() .. " equipping", delay, conditional, success, failure, ply,
		ply:GetPos(), self
	);
	ply:Emote(MS.Config["Weapon Timers"]["Equip Message"]["Start"]);
	return false -- Removing the weapon from your inventory is handled in the timer
end
