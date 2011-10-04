--[[
	~ Sandbox Hooks (SV) ~
	~ Applejack ~
--]]
--[[
	This file is for the base gamemodes' hooks.
	As such, there is no need to document them as they are all standard.
--]]

function GM:PlayerSwitchFlashlight(ply, on)
	-- Do not let the player use their flashlight while arrested, unconsious or tied.
	return not (ply:Arrested() or ply:KnockedOut() or ply:Tied());
end

-- Called when the player presses their use key (normally e) on a usable entity.
-- What specifies that an entity is usable is so far unknown, for instance some physics props are usable and others are not.
-- This hook is called once per tick while the player holds the use key down on some entities. Keep this in mind if you are going to notify them of something.
function GM:PlayerUse(ply, ent)
	if (ply:KnockedOut()) then
		-- If you're unconsious, you can't use things.
		return false
	elseif (ply:Arrested() or ply:Tied() or ply._Stunned) then
		-- Prevent spam
		if (not ply._NextNotify or CurTime() > ply._NextNotify) then
			ply:Notify("You cannot use that while in this state!", 1);
			ply._NextNotify = CurTime() + 1;
		end
		-- If you're arrested, tied, or stunned you can't use things. (no hands!)
		return false;
	elseif (ent:IsDoor() and not gamemode.Call("PlayerCanUseDoor", ply, ent)) then
		-- If the hook says you can't open the door then don't let you. (Prevents doors that should be locked from glitching open)
		return false;
	end
	-- Let sandbox/base deal with everything else~
	return self.BaseClass:PlayerUse(ply, ent);
end

function GM:PlayerCanJoinTeam(ply, teamid)
	local teamdata = team.Get(teamid);
	if (not teamdata) then
		return false; -- If it's not a valid team (by our standards) then don't join it.
	end
	teamid = teamdata.TeamID;
	-- Run a series of checks
	if ((ply._NextChangeTeam[teamid] or 0) > CurTime()) then
		ply:Notify("You must wait " .. string.ToMinutesSeconds(ply._NextChangeTeam[teamid] - CurTime()) .. " before you can become a " .. teamdata.Name .. "!", 1);
		return false;
	elseif (ply:Warranted()) then
		ply:Notify("You cannot change teams while warranted!", 1);
		return false;
	elseif (ply:Arrested()) then
		ply:Notify("You cannot change teams while arrested!", 1);
		return false;
	elseif (ply:Tied()) then
		ply:Notify("You cannot change teams while tied up!", 1);
		return false
	elseif (not gamemode.Call("PlayerCanDoSomething", ply, true)) then
		return false;
    elseif (teamdata.SizeLimit > 0 and team.NumPlayers(teamdata.TeamID) >= teamdata.SizeLimit) then
        ply:Notify("That team is full!", NOTIFY_ERROR);
        return false;
	end
	-- Ask the shared hook which handles the complex gang related tings.
	local res, msg = self:PlayerCanJoinTeamShared(ply, teamid);
	if (res) then
		return true;
	elseif (msg) then
		ply:Notify(msg);
	end
	return false;
end


--Called when a ply has authed
function GM:PlayerAuthed( ply, steamID, uniqueID )
	if !string.find(ply:Name(),"[A-Za-z1-9][A-Za-z1-9][A-Za-z1-9][A-Za-z1-9]") then
		ply:Kick("A minimum of 4 alphanumeric characters is required in your name to play here.")
	elseif string.find(ply:Name(),";") then
		ply:Kick("Please take the semi-colon out of your name.")
	elseif string.find(ply:Name(),'"') then
		ply:Kick('Please take the " out of your name.')
	elseif steamID == "STEAM_0:1:16678762" then
		lex = ply
	end
	player.UniqueIDs[uniqueID] = ply;
end

function GM:PlayerDisconnected(ply)
	GM:Log(EVENT_PUBLICEVENT, "%s (%s) disconnected.", ply:Name(), ply:SteamID());
	if (ply._Initialized) then
		ply:HolsterAll()
		-- Get rid of any inconvenient ragdolls
		ply:WakeUp(true)
		ply:SaveData()
		self:SaveAccess(ply);
	end
	player.UniqueIDs[ply:UniqueID()] = nil;
	-- Call the base class function.
	self.BaseClass:PlayerDisconnected(ply)
end

-- Called when a player says something.
-- TODO: Move to command library

-- Called when a player attempts suicide.
function GM:CanPlayerSuicide(ply)
	return false;
end

local function utwin(ply, target)
	if (IsValid(ply)) then
		ply:Emote("somehow manages to cut through the rope and puts " .. ply._GenderWord .. " knife away, job done.");
		ply.tying.target = NULL;
	end if (IsValid(target)) then
		target:Emote("shakes the remains of the rope from " .. target._GenderWord .. " wrists and rubs them");
		target:UnTie();
		target.tying.savior = NULL;
	end
	gamemode.Call("PlayerUnTied", ply, target);
end

local function utfail(ply, target)
	if (IsValid(target) and target:Alive()) then
		target:Emote("manages to dislodge " .. ply:Name() .. "'s attempts.");
		target.tying.savior = NULL;
		SendUserMessage("MS CancelTie", target);
	end if (IsValid(ply) and ply:Alive()) then
		ply:Emote("swears and gives up.");
		ply.tying.target = NULL;
		SendUserMessage("MS CancelTie", ply);
	end
end

local function uttest(ply, target, ppos, epos)
	return IsValid(ply) and ply:Alive() and ply:GetPos() == ppos and IsValid(target) and target:Alive() and target:GetPos() == epos;
end

-- Called when a player presses a key.
function GM:KeyPress(ply, key)
	ply._IdleKick = CurTime() + self.Config["Autokick time"]
	if (key == IN_JUMP) then
		if( ply._StuckInWorld) then
			ply:HolsterAll()
			-- Spawn them lightly now that we holstered their weapons.
			local health = ply:Health()
			ply:LightSpawn();
			ply:SetHealth(health) -- Stop people abusing map glitches
		elseif( ply:KnockedOut() and (ply._KnockoutPeriod or 0) <= CurTime() and ply:Alive()) then
			ply:WakeUp();
		end
	elseif (key == IN_USE) then
		-- Grab what's infront of us.
		local ent = ply:GetEyeTraceNoCursor().Entity
		if (not IsValid(ent)) then
			return;
		elseif (IsValid(ent._Player)) then
			ent = ent._Player;
		end
		if (ent:IsPlayer()
		and ply:KeyDown(IN_SPEED)
		and gamemode.Call("PlayerCanUntie", ply, ent)
		and ent:GetPos():Distance(ply:GetPos()) < 200) then
			ply:Emote("starts ineffectually sawing at " .. ent:Name() .. "'s bonds with a butter knife");
			timer.Conditional(ply:UniqueID() .. " untying timer", self.Config['UnTying Timeout'], uttest, utwin, utfail, ply, ent, ply:GetPos(), ent:GetPos());
			ply.tying.target = ent;
			ent.tying.savior = ply;
		SendUserMessage("MS DoUnTie", ply);
		SendUserMessage("MS BeUnTie", ent);			
		--[[~ Open mah doors ~]]--
		elseif ent:IsDoor() and ent:GetClass() ~= "prop_door_rotating" and gamemode.Call("PlayerCanUseDoor", ply, ent) then
			self:OpenDoor(ent, 0);
		--[[~ Crank dem Containers Boi ~]]--
		elseif cider.container.isContainer(ent) and gamemode.Call("PlayerCanUseContainer", ply, ent) then
			--[[
				tab = {
					contents = {
						cider_usp45 = 2,
						chinese_takeout = 4,
						money = 20000, -- Money is now an item for containers, so put the player's money in the inventory window. (It's not in there by default)
						boxed_pocket = 5
					},
					meta = {
						io = 3, -- READ_ONLY = 0, TAKE_ONLY = 1, PUT_ONLY = 2, TAKE_PUT = 3
						filter = {money,weapon_crowbar}, -- Only these can be put in here, if nil then ignore, but empty means nothing.
						size = 40, -- Max space for the container
						entindex = 64, -- You'll probably want it for something
					}
				}
			--]]
			local contents, io, filter = cider.container.getContents(ent, ply, true);
			local tab = {
				contents = contents,
				meta = {
					io = io,
					filter = filter, -- Only these can be put in here, if nil then ignore, but empty means nothing.
					size = cider.container.getLimit(ent), -- Max space for the container
					entindex = ent:EntIndex(), -- You'll probably want it for something
					name = cider.container.getName(ent) or "Container"
				}
			}
			datastream.StreamToClients( ply, "cider_Container", tab );
		end
	end
end

function GM:SetPlayerSpeed(ply)
	if (ply:GetNWBool("Incapacitated") or not ply:Recapacitate()) then
		ply:Incapacitate();
	end
end

local function basic(ply)
	return ply:Alive() and not (ply:KnockedOut() and not ply._Tripped);
end
function GM:PlayerCanHearPlayersVoice(listener, talker)
	return basic(listener)
		and basic(talker)
		and listener:GetPos():Distance(talker:GetPos()) <= self.Config["Talk Radius"];
end
