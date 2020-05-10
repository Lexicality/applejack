--
-- ~ Arrests, warrants etc ~
-- ~ Applejack ~
--
function PLUGIN:SetPlayerDefaultData(ply, data)
	data._Arrested = false
end

function PLUGIN:PlayerDataLoaded(ply, success)
	ply._Warranted = false;
	ply._CannotBeWarranted = 0;
	-- TODO: Can this be plugin config?
	ply._ArrestTime = MS.Config["Arrest Time"];

	-- If they disconnected while arrested, re-arrest them
	if ply.cider._Arrested then
		ply:Arrest()
	end
end

function PLUGIN:PlayerSpawn(ply)
	if ply._Initialized and not ply._LightSpawn then
		ply._CannotBeWarranted = CurTime() + 15
	end
end

function PLUGIN:PlayerCanRamPlayersDoor(ply, victim, door)
	if victim:Warranted() then
		return true
	elseif door:GetOwner() == victim and victim:Arrested() then
		return true
	end
end

function PLUGIN:PlayerCanLockpick(ply, ent)
	if ent:IsPlayer() and ent:Arrested() then
		return true
	end
end

function PLUGIN:PlayerCanJoinTeam(ply, teamid)
	if ply:Warranted() then
		ply:Notify("You cannot change teams while warranted!", 1)
		return false
	elseif ply:Arrested() then
		ply:Notify("You cannot change teams while arrested!", 1)
		return false
	end
end

function PLUGIN:PlayerCanDemote(ply, target)
	if target:Arrested() then
		return false,
       		"You cannot demote " .. target:Name() .. " while they're arrested!"
	end
end

function PLUGIN:PlayerNoClip(ply)
	if ply:Arrested() then
		return false
	end
end

-- "something"?
function PLUGIN:PlayerCanDoSomething(ply, ignorealive, spawning)
	if ply:Arrested() then
		ply:Notify("You cannot do that while arrested!", 1)
		return false
	end
end

function PLUGIN:PlayerCanUseCommand(ply, cmd, args)
	if not ply:Arrested() or not ply:Alive() or player:KnockedOut() then
		return
	end

	if cmd == "dropmoney" or cmd == "givemoney" then
		-- Allow bribes
		return true
	elseif cmd == "me" or cmd == "y" or cmd == "w" then
		-- Allow emotes
		return true
	end

	ply:Notify("You cannot do that while arrested!", 1)
	return false;
end

function PLUGIN:PlayerCanTie(ply, victim)
	if victim:Arrested() then
		ply:Notify(

			
				"The person's large metal wrist ornaments prevent you from finding a place to put the rope.",
				NOTIFY_ERROR
		);
		return false;
	end
end

function PLUGIN:PlayerCanBeRecapacitated(ply)
	if ply:Arrested() then
		return false
	end
end

function PLUGIN:PlayerCanRecieveWeapons(ply)
	if ply:Arrested() then
		return false
	end
end

function PLUGIN:PlayerSwitchFlashlight(ply, on)
	if ply:Arrested() then
		return false
	end
end

-- Called when the player presses their use key (normally e) on a usable entity.
-- What specifies that an entity is usable is so far unknown, for instance some physics props are usable and others are not.
-- This hook is called once per tick while the player holds the use key down on some entities. Keep this in mind if you are going to notify them of something.
function PLUGIN:PlayerUse(ply, ent)
	if ply:Arrested() then
		if not ply._NextNotify or CurTime() > ply._NextNotify then
			ply:Notify("You cannot use that while arrested!", 1);
			ply._NextNotify = CurTime() + 1
		end
		return false
	end
end

function PLUGIN:DoPlayerDeath(ply)
	ply:UnWarrant()
	ply:UnArrest(true)
end

function PLUGIN:PlayerChangedTeams(ply, oldteam, newteam)
	ply:UnWarrant()
end
