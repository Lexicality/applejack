--
-- ~ Lockpick SWep ~ Clientside ~
-- ~ Applejack ~
--
IncludeCS("shared.lua");
AddCSLuaFile("cl_init.lua");
umsg.PoolString("dosnd");

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);

	-- Set the animation of the owner to one of them attacking.
	-- self.Owner:SetAnimation(PLAYER_ATTACK1);

	local tr = self.Owner:GetEyeTrace();
	local owner = self.Owner;
	if (owner:GetShootPos():Distance(tr.HitPos) > 128 or not IsValid(tr.Entity)) then
		self:SendWeaponAnim(ACT_VM_MISSCENTER);
		self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
		return;
	end
	self:SendWeaponAnim(ACT_VM_HITCENTER);
	local ent = tr.Entity;
	local res, err = gamemode.Call("PlayerCanLockpick", owner, ent)
	if (not res) then
		owner:Notify(err or "You can't lockpick this!", 1);
		self:DoSound(3)
		return;
	end
	ent._LockpickingCount = ent._LockpickingCount or 0;
	-- Announce that we have started lockpicking, if we have.
	if (ent._LockpickingCount == 0) then
		owner:Emote("starts fiddling about with the lock");
	end
	owner._LockpickChance = owner._LockpickChance or 0;
	-- An entity can specify the max hits it takes to unlock them
	local maxhits = ent._LockpickHits or GM.Config["Maximum Lockpick Hits"];
	-- Padlocks double the number of hits
	if (ent:GetNWBool("Padlocked")) then
		maxhits = maxhits * 2;
	end
	-- I'm not sure why, but it's still really easy to lockpick things with a high chance. Let's force it harder.
	maxhits = maxhits * 11;
	-- Update the count
	ent._LockpickingCount = ent._LockpickingCount + (1 / maxhits);
	-- Give the pick a chance of breaking
	if (math.random() < owner._LockpickChance) then
		-- Tell the world with text'n'noise
		self:DoSound(2)
		owner:Emote("manages to snap their lockpick off in the lock.");
		-- Reset the lock
		ent._LockpickingCount = 0;
		-- Reset the break chance
		owner._LockpickChance = 0;
		-- Remove the lockpick from the player
		owner:StripWeapon("cider_lockpick");
		owner:SelectWeapon("cider_hands");
		-- End the picking
		return;
		-- Check if we have NOT managed to pick the lock
	elseif (math.random() > ent._LockpickingCount) then
		-- Make a fiddling with the lock sound
		self:DoSound(0)
		return;
	end
	-- We have successfully picked the lock! Tell people.
	owner:Emote(
		"opens the lock with a final thrust, slightly damaging their lockpick"
	)
	self:DoSound(1)
	-- Reset the lock
	ent._LockpickingCount = 0;
	-- Add to the lockpicker's pick break chance and tell them.
	owner._LockpickChance = owner._LockpickChance +
                        		GM.Config["Lockpick Break Chance"];
	-- Since we can now pick the cuffs on players to unarrest them, we need to treat them differently.
	if (ent:IsPlayer()) then
		ent:UnArrest();
		ent:Emote(

			
				"pulls off the unlocked handcuffs and throws them away hard enough to break them."
		);
		GM:Log(
			EVENT_EVENT, "%s picked the lock on %s handcuffs", ply:Name(), ent:Name()
		);
		return;
	end
	-- Actually unlock it the entity
	ent:UnLock();
	-- ent:EmitSound("doors/door_latch3.wav");
	local event, addon, entname = "", "", ent._eName or "entity";
	if (ent:IsOwned()) then
		event = ent:GetPossessiveName();
	else
		event = "an unowned";
	end
	if (ent._isDoor) then
		addon = ent:GetDoorName();
		if (addon ~= "") then
			addon = ": " .. addon;
		end
	else
		local name = gamemode.Call("GetEntityName", ent);
		if (name and name ~= "") then
			addon = ": " .. name;
		end
	end
	GM:Log(
		EVENT_EVENT, "%s picked the lock on %s %s%s.", owner:GetName(), event,
		entname, addon
	);
end
