--[[
	~ Commands ~
	~ Applejack ~
--]]

cider.command.add("fuck","b",0,function(p)
	p:Notify("FUCK!", 1);
end,"Commands", "", "Free gratuitous swearing");

--[[ ADMIN ABUSE COMMANDS ]]--
--[[
	These are only here at the insistance of my admins. They only apply to SuperAdmins, who probably can be trusted.
	If yours can't be trusted, delete the space between the [s as shown below.
--]]
--[ [<--Delete the space between these [s if you want to disable the abuse commands

-- Knock out one person for an optional amount of time. Will default to 5.
cider.command.add("knockout","s",1,function(ply, target, time)
	local victim = player.Get(target);
	if (victim) then
		victim:KnockOut(tonumber(time) or 5);
		GM:Log(EVENT_EVENT, "%s knocked out %s", ply:Name(), victim:Name());
	else
		return false, "Invalid player '"..target.."'!";
	end
end, "Super Admin Abuse Commands", "<player> [time]", "Knock a player out", true);

-- Wake a player up
cider.command.add("wakeup","s",1,function(ply, target)
	local victim = player.Get(target);
	if (victim) then
		victim:WakeUp();
		GM:Log(EVENT_EVENT, "%s woke up %s", ply:Name(), victim:Name());
	else
		return false, "Invalid player '"..target.."'!";
	end
end, "Super Admin Abuse Commands", "<player>", "wake a player up", true);

local function knockoutfunct(tbl,tiem)
	local target = table.remove(tbl);
	if (IsValid(target)) then
		target:KnockOut(tiem);
	end
end
-- Knock out everyone for a specified time. (Try not to use)
cider.command.add("knockoutall","s",0,function(ply, time)
	local tbl = player.GetAll();
	player.NotifyAll(NOTIFY_GENERIC, "%s knocked everyone out .", ply:Name());
	timer.Create(ply:Name().." admin abuse knockout", 0, #tbl,knockoutfunct, tbl, tonumber(time) or 5);
end, "Super Admin Abuse Commands", "[time]", "Knock out all players", true);

local function unknockoutfunct(tbl)
	local target = table.remove(tbl);
	if (IsValid(target)) then
		target:WakeUp();
	end
end
-- Wake everyone up
cider.command.add("wakeupall","s",0,function(ply)
	local tbl = player.GetAll();
	player.NotifyAll(NOTIFY_GENERIC, "%s woke everyone up.", ply:Name());
	timer.Create(ply:Name().." admin abuse unknockout", 0, #tbl,unknockoutfunct, tbl);
end, "Super Admin Abuse Commands", "[time]", "wake up all players");

-- Tie a player up
cider.command.add("tie","s",1,function(ply, target)
	local victim = player.Get(target);
	if (victim) then
		victim:TieUp();
		GM:Log(EVENT_EVENT, "%s tied up %s", ply:Name(), victim:Name());
	else
		return false, "Invalid player '"..target.."'!";
	end
end, "Super Admin Abuse Commands", "<player>", "tie a player", true);

cider.command.add("untie","s",1,function(ply, target)
	local victim = player.Get(target);
	if (victim) then
		victim:UnTie();
		GM:Log(EVENT_EVENT, "%s untied %s", ply:Name(), victim:Name());
	else
		return false, "Invalid player '"..target.."'!";
	end
end, "Super Admin Abuse Commands", "<player>", "untie a player", true);

-- There were '(un)tieall' commands here but they were removed.

-- Respawn a player completely
cider.command.add("spawn","s",1,function(ply, target)
	local victim = player.Get(target);
	if (victim) then
		victim:Spawn();
		GM:Log(EVENT_EVENT, "%s respawned %s", ply:Name(), victim:Name());
	else
		return false, "Invalid player '"..target.."'!";
	end
end, "Super Admin Abuse Commands", "<player>", "respawn a player", true);

-- Arrest a player with optional arrest time
cider.command.add("arrest","s",1,function(ply, target, time)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	victim:Arrest(tonumber(time));
	GM:Log(EVENT_EVENT, "%s arrested %s", ply:Name(), victim:Name());
end, "Super Admin Abuse Commands", "<player> [time]", "arrest a player", true);

-- Unarrest a player
cider.command.add("unarrest","s",1,function(ply, target)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	victim:UnArrest();
	GM:Log(EVENT_EVENT, "%s unarrested %s", ply:Name(), victim:Name());
end, "Super Admin Abuse Commands", "<player>", "unarrest a player", true);

-- Give a player an instant warrant with optional length
cider.command.add("awarrant","s",2,function(ply, target, kind, time)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	kind = string.lower(kind);
	if (kind ~= "arrest" and kind ~= "search") then
		return false, "Invalid warrant type '"..kind.."'!";
	end
	time = tonumber(time);
	GM:Log(EVENT_EVENT,"%s gave %s a %s warrant for %s seconds", ply:Name(), victim:Name(), kind, time or "default");
	victim:Warrant(kind, time);
end, "Super Admin Abuse Commands", "<player> <warrant> [time]", "warrant a player without going through the normal routes", true);

-- Give a player a named SWep/HL2 gun
cider.command.add("give","s",2,function(ply, target, kind)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	if (not IsValid(victim:Give(kind))) then
		return false, "Invalid weapon '"..kind.."'!";
	end
	GM:Log(EVENT_EVENT, "%s gave %s a %s", ply:Name(), victim:Name(), kind);
end, "Super Admin Abuse Commands", "<player> <swep>", "give a player a named swep (ie cider_baton)", true);

-- give a player some ammo
cider.command.add("giveammo","s",2,function(ply, target, kind, amount)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	amount = tonumber(amount) or 20
	victim:GiveAmmo(amount, kind);
	GM:Log(EVENT_EVENT, "%s gave %s %s %s ammo", ply:Name(), victim:Name(), amount, kind);
end, "Super Admin Abuse Commands", "<player> <ammo> [amoun]", "give a player named ammo (ie SMG1_Grenade)", true);

-- Give or take items away from players.
cider.command.add("giveitem", "s", 2, function(ply, target, name, amount, force)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	local item = GM:GetItem(name);
	if (not item) then
		return false, "Invalid item '"..name.."'!";
	end
	if (amount == "force") then -- Some people use the old (silly) order. They really shouldn't by now but meh. Luckily they tend to use 'force' instead of 'true'.
		ply:Notify("YOU'RE DOING IT WRONG GODDAMNIT JOIN THE NEW WORD ORDER", 1);
		ply:Notify("Puns are the best form of humor. Reguardless, the syntax IS /giveitem "..target.." "..name.." "..(tonumber(force) or 1).." force, not /giveitem "..target.." "..name.." force "..(tonumber(force) or 1)..".");
		ply:Notify("Please remember the order. This warning will not always work properly.");
		amount,force = force, amount;
	end	
	amount = tonumber(amount) or 1;
	force = tobool(force);
	if (amount == 0) then
		return false, "What is the point of doing that?";
	elseif (amount * item.Size > 50) then -- Something that not everyone bears in mind. (Including me occasionally.)
		ply:Notify("Warning: You are giving "..victim:Name().." more items than players can normally fit in their inventories. Experience has shown this if often a bad idea if done to anyone not part of the cabal. Remember you can remove items with negative numbers.");
	end
	local s,f = cider.inventory.update(victim, item.UniqueID, amount, force);
	if (not s) then
		return false, f;
	end
	-- Do tha loggin
	if (amount == 1) then
		amount = "a";
		name = item.Name;
	else
		name = item.Plural;
	end
	local person = "themselves";
	if (ply ~= victim) then
		person = victim:Name();
		victim:Notify(ply:Name() .. " has given you " .. amount .. " " .. name .. ".", 0);
	end
	player.NotifyByAccess("s", ply:Name() .. " gave " .. person .. " " .. amount .. " " .. name .. ".", 0);
	GM:Log(EVENT_SUPEREVENT, "%s gave %s %s %s.", ply:Name(), person, amount, name);
end, "Super Admin Abuse Commands", "<player> <item> [number] [force]", "Give an item to a player. (Or take it away with negative numbers.)", true);

--]
--[[
	The following abuse commands apply to all admins.
	If you do not want them, do as above.
--]]

--[ [ <-- Space to remove.

-- Set a player to a particular team (ignoring all restrictions like team size)
cider.command.add("setteam","a",2,function(ply, target, targetteam)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	local tdata = team.Get(targetteam);
	if (not tdata) then
		return false, "Invalid team '"..targetteam.."'!";
	end
	victim:JoinTeam(tdata.TeamID);
	GM:Log(EVENT_EVENT,"%s set %s's team to %q", ply:Name(), victim:Name(), tdata.Name);
end, "Admin Abuse Commands", "<player> <team>", "set a player's team", true);

cider.command.add("invisible","a",0,function(ply, target)
	local victim
	if (target) then
		victim = player.Get(target);
		if (not victim) then
			return false, "Invalid player '"..target.."'!";
		end
	else
		victim = ply;
	end
	if (victim:GetColor() == 0) then
		victim:SetColor(255,255,255,255)
		victim:DrawShadow(true);
		victim:Notify("You are now visible",0);
		if (ply ~= victim) then
			ply:Notify(victim:Name() .. " is now visible.",0);
		end
	else
		victim:SetColor(0,0,0,0)
		victim:DrawShadow(false);
		victim:Notify("You are now invisible",0);
		if (ply ~= victim) then
			ply:Notify(victim:Name() .. " is now invisible.",0);
		end
	end
end, "Admin Abuse Commands","[target]","Make yourself or someone else invisible.", true)

cider.command.add("setmodel","a",2,function(ply, target, model)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	elseif (not util.IsValidModel(model)) then
		return false, "Invalid model!";
	end
	victim:SetModel(model);
	GM:Log(EVENT_EVENT,"%s set %s's model to %q", ply:Name(), victim:Name(), model);
end, "Admin Abuse Commands", "<name> <model>","Override the player's current model.", true)

cider.command.add("notify", "a", 3, function(ply, target, level, ...)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	local words = string.Trim(table.concat({...}, " "));
	--<chat|drip/0|error/1|bip/2|tic/3>
	level = string.lower(level);
	if (level == "drip") then
		level = 0;
	elseif (level == "error") then
		level = 1;
	elseif (level == "undo") then
		level = 2;
	elseif (level == "bell") then
		level = 3;
	end
	level = tonumber(level);
	victim:Notify(words, level);
	GM:Log(EVENT_SUPEREVENT, "%s sent %s a level %s notification saying %q", ply:Name(), victim:Name(), level or "chat", words);
end, "Admin Abuse Commands", "<player> <chat|drip/0|error/1|undo/2|bell/3> <words>", "Send a player a notification using the built in system.", true);
cider.command.add("notifyall", "a", 2, function(ply, level, ...)
	local words = string.Trim(table.concat({...}, " "));
	--<chat|drip/0|error/1|bip/2|tic/3>
	level = string.lower(level);
	if (level == "drip") then
		level = 0;
	elseif (level == "error") then
		level = 1;
	elseif (level == "undo") then
		level = 2;
	elseif (level == "bell") then
		level = 3;
	end
	level = tonumber(level);
	player.NotifyAll(level, "%s", words); -- Feeelthy hack to prevent unwanted stacking in the pooled string table.
	GM:Log(EVENT_SUPEREVENT, "%s sent %s a level %s notification saying %q", ply:Name(), "everyone", level or "chat", words);
end, "Admin Abuse Commands", "<chat|drip/0|error/1|undo/2|bell/3> <words>", "Send a player a notification using the built in system.", true);
--]]
--[[ END OF ADMIN ABUSE COMMANDS ]]--



cider.command.add("giveaccess", "s", 2, function(ply, target, flags)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	flags:gsub("[asm%s]", "");
	if (flags == "") then
		return false;
	end
	victim:GiveAccess(flags);
	player.NotifyAll(NOTIFY_CHAT, "%s gave %s access to the %q flag%s", ply:Name(), victim:Name(), flags, flags:len() > 1 and "s" or "");
end, "Super Admin Commands", "<player> <access>", "Give access to a player.", true);

-- A command to take access from a player.
cider.command.add("takeaccess", "s", 2, function(ply, target, flags)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	flags:gsub("[asm%s]", "");
	if (flags == "") then
		return false;
	end
	victim:TakeAccess(flags);
	player.NotifyAll(NOTIFY_CHAT, "%s took %s's access to the %q flag%s", ply:Name(), victim:Name(), flags, flags:len() > 1 and "s" or "");
end, "Super Admin Commands", "<player> <access>", "Take access from a player.", true);


cider.command.add("restartmap", "a", 0, function(ply)
	for _, pl in pairs(player.GetAll()) do
		pl:HolsterAll();
		pl:SaveData();
	end
	player.NotifyAll(NOTIFY_CHAT, "%s restarted the map!", ply:Name());
	game.ConsoleCommand("changelevel "..game.GetMap().."\n");
end, "Admin Commands", "", "Restart the map immediately.");

local function getnamething(kind,thing)
	if kind == "team" then
	-- Team blacklist
		local team = team.Get(thing)
		if		not team			then return false,thing.." is not a valid team!"
		elseif  not team.Blacklist	then return false, team.Name.." isn't blacklistable!"
		end
		return team.Name, team.TeamID
	elseif kind == "item" then
	-- Item blacklist
		local  item = GM:GetItem(thing)
		if not item then return false,thing.." is not a valid item!" end
		return item.Name, item.UniqueID
	elseif kind == "cat" then
	-- Category blacklist
		local  cat = GM:GetCategory(thing)
		if not cat then return false,thing.." is not a valid category!" end
		return cat.Name, cat.index;
	elseif kind == "cmd" then
	-- Command blacklist
		local cmd = cider.command.stored[thing]
		if not cmd then return false,thing.." is not a valid command!" end	
		return thing, thing;
	else
		return false,thing.." is not a valid blacklist type! Valid: team/item/cat/cmd"
	end
end
local function getBlacklistTime(time)
	if (time >= 1440) then
		return math.ceil(time / 1440) .. " days";
	elseif (time >= 60) then
		return math.ceil(time / 60) .. " hours";
	else 
		return time .. " minutes";
	end
end
-- A command to blacklist a player from a team.
--/blacklist chronic team police 0 "asshat"
-- team/item/cat/cmd
--<name> <type> <thing> <time> <reason>
--TODO: Make a vgui to handle this shit.
cider.command.add("blacklist", "m", 5, function(ply, target, kind, thing, time, ...)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	kind, thing, time = string.lower(kind), string.lower(thing), tonumber(time);
	if (time < 1) then
		return false, "You cannot blacklist for less than a minute!";
	elseif ((time > 10080 and not ply:IsSuperAdmin()) or (time > 1440 and not ply:IsAdmin())) then
		return false, "You cannot blacklist for that long!";
	end
	local reason = table.concat({...}, " "):sub(1,65):Trim();
	if (not reason or reason == "" or (reason:len() < 5 and not ply:IsSuperAdmin())) then
		return false, "You must specify a reason!";
	end
	-- Get the name of what we're doing and the thing itself.
	local name, thing = getnamething(kind, thing);
	if (not name) then
		return false, thing;
	end
	if (victim:Blacklisted(kind, thing) ~= 0) then
		return false, victim:Name() .. " is already blacklisted from that!";
	end
	if (not gamemode.Call("PlayerCanBlacklist", ply, victim, kind, thing, time, reason)) then
		return false;
	end
	gamemode.Call("PlayerBlacklisted", victim, kind, thing, time, reason, ply);
	victim:Blacklist(kind, thing, time, reason, ply:Name());
	time = getBlacklistTime(time);
	player.NotifyAll(NOTIFY_CHAT, "%s blacklisted %s from using %s for %s for %q.", ply:Name(), victim:Name(), name, time, reason);
end, "Moderator Commands", "<player> <team|item|cat|cmd> <thing> <time> <reason>", "Blacklist a player from something", true);

cider.command.add("unblacklist", "m", 3, function(ply, target, kind, thing)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	kind, thing = string.lower(kind), string.lower(thing);
	-- Get the name of what we're doing and the thing itself.
	local name, thing = getnamething(kind, thing);
	if (not name) then
		return false, thing;
	end
	if (victim:Blacklisted(kind, thing) == 0) then
		return false, victim:Name() .. " is not blacklisted from that!";
	end
	if (not gamemode.Call("PlayerCanUnBlacklist", ply, victim, kind, thing)) then
		return false;
	end
	gamemode.Call("PlayerUnBlacklisted", victim, kind, thing, ply);
	victim:UnBlacklist(kind, thing);
	player.NotifyAll(NOTIFY_CHAT, "%s unblacklisted %s from using %s.", ply:Name(), victim:Name(), name);
end, "Moderator Commands", "<player> <team|item|cat|cmd> <thing>", "Unblacklist a player from something", true)

cider.command.add("blacklistlist", "m", 1, function(ply, target)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	local blacklist = victim.cider._Blacklist;
	if (table.Count(blacklist) == 0) then
		return false, victim:Name() .. " isn't blacklisted from anything!";
	end
	local printtable, words = {};
	local namelen, adminlen, timelen = 0, 0, 0;
	local time, name, admin, reason
	for kind, btab in pairs(blacklist) do
		if (table.Count(btab) == 0) then
			blacklist[kind] = nil;
		else
			words = {};
			for thing in pairs(btab) do
				time, reason, admin = victim:Blacklisted(kind, thing);
				if (time ~= 0) then
					name = getnamething(kind, thing);
					time = getBlacklistTime(time);
					if ( name:len() > namelen ) then  namelen = name:len();  end
					if (admin:len() > adminlen) then adminlen = admin:len(); end
					if (time:len()  > timelen ) then  timelen = time:len();  end
					words[#words + 1] = {name, time, admin, reason};
				end
			end
			if (#words ~= 0) then
				printtable[#printtable + 1] = {kind, words};
			end
		end
	end
	if (#printtable == 0) then
		return false, victim:Name() .. " isn't blacklisted from anything!";
	end
	local a,b,c = ply.PrintMessage, ply, HUD_PRINTCONSOLE;
	-- A work of art in ASCII formatting. A shame it is soon to be swept away
		a(b,c, "----------------------------[ Blacklist Details ]-----------------------------");
		local w = "%-" .. namelen + 2 .. "s| %-" .. timelen + 2 .. "s| %-" .. adminlen + 2 .. "s| %s";
		a(b,c,w:format("Thing", "Time", "Admin", "Reason"));
		for _,t in ipairs(printtable) do
			a(b,c, "-----------------------------------[ "..string.format("%-4s",t[1]).." ]------------------------------------");
			for _,t in ipairs(t[2]) do
				a(b,c,w:format(t[1], t[2], t[3], t[4]));
			end
		end
	-- *sigh*
	player:Notify("Blacklist details have been printed to your console.",0);
end, "Moderator Commands", "<player>", "Print a player's blacklist to your console (temp)", true);

-- A command to demote a player.
cider.command.add("demote", "b", 2, function(ply, target, ...)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	end
	local reason = table.concat({...}, " "):sub(1,65):Trim();
	if (not reason or reason == "" or (reason:len() < 5 and not ply:IsSuperAdmin())) then
		return false, "You must specify a reason!";
	end
	local res, msg = gamemode.Call("PlayerCanDemote", ply, victim);
	if (not res) then
		return false, msg;
	end
	local tid = victim:Team();
	victim:Demote();
	player.NotifyAll(NOTIFY_CHAT, "%s demoted %s from %s for %q.", ply:Name(), victim:Name(), team.GetName(tid), reason);
end, "Commands", "<player> <reason>", "Demote a player from their current team.", true);

cider.command.add("save", "s", 0, function(ply)
	player.SaveAll()
	GM:Log(EVENT_PUBLICEVENT,"%s saved everyone's profiles.", ply:Name())
end, "Super Admin Commands", "", "Forceably save all profiles")

-- A command to privately message a player.
cider.command.add("pm", "b", 2, function(ply, target, ...)
	local victim = player.Get(target);
	if (not victim) then
		return false, "Invalid player '"..target.."'!";
	elseif (victim == ply) then
		return false, "You can't PM yourself.";
	end
	local words = table.concat({...}, " "):sub(1,125):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	GM:Log(EVENT_SUPEREVENT, "%s pmed %s: %s",ply:Name(), victim:Name(), words)
	-- Print a message to both players participating in the private message.
	cider.chatBox.add(victim, ply, "pm", words);
	words = "@" ..    victim:Name() .. " " .. words;
	cider.chatBox.add(ply,    ply, "pm", words);
end, "Commands", "<player> <text>", "Send an OOC private messsage to a player.", true);

-- A command to give a player some money.
cider.command.add("givemoney", "b", 1, function(ply, amt)
	local victim = ply:GetEyeTraceNoCursor().Entity;
	if (not (IsValid(victim) and victim:IsPlayer())) then
		return false, "You must look at a player to give them money!";
	end
	amt = tonumber(amt);
	if (not amt or amt < 1) then
		return false, "You must specify a valid amount of money!";
	end
	amt = math.floor(amt);
	if (not ply:CanAfford(amt)) then
		return false, "You do not have enough money!";
	end
	ply:GiveMoney(-amt);
	victim:GiveMoney(amt);
	
	ply:Emote("hands " .. victim:Name() .. " a wad of money.");
	
	ply:Notify("You gave " .. victim:Name() .. " $" .. amt .. ".", 0);
	victim:Notify(ply:Name() .. " gave you $" .. amt .. ".", 0);
	GM:Log(EVENT_EVENT, "%s gave %s $%i.", ply:Name(), victim:Name(), amt);
end, "Commands", "<amount>", "Give some money to the player you're looking at.", true);

-- A command to drop money.
cider.command.add("dropmoney", "b", 1, function(ply, amt)
	-- Prevent fucktards spamming the dropmoney command.
	ply._NextMoneyDrop = ply._NextMoneyDrop or 0;
	if ((ply._NextMoneyDrop or 0) > CurTime()) then
		return false, "You need to wait another " .. (ply._NextMoneyDrop - CurTime()).. " seconds before dropping more money.";
	end
	local pos = ply:GetEyeTraceNoCursor().HitPos;
	if (ply:GetPos():Distance(pos) > 255) then
		pos = ply:GetShootPos() + ply:GetAimVector() * 255;
	end
	amt = tonumber(amt);
	if (not amt or amt < 1) then
		return false, "You must specify a valid amount of money!";
	end
	amt = math.floor(amt);
	if (not ply:CanAfford(amt)) then
		return false, "You do not have enough money!";
	elseif (amt < 25) then -- Fucking spammers again.
		return false, "You cannot drop less than $25.";
	end
	ply._NextMoneyDrop = CurTime() + 30;
	ply:GiveMoney(-amt);
	cider.propprotection.PlayerMakePropOwner(GM.Items["money"]:Make(pos, amt), ply, true);
	GM:Log(EVENT_EVENT,"%s dropped $%i.", ply:Name(), amt);
end, "Commands", "<amount>", "Drop some money where you are looking.", true);

cider.command.add("note", "b", 1, function(ply, ...)
	if (ply:GetCount("notes") == GM.Config["Maximum Notes"]) then
		return false, "You've hit the notes limit!";
	end
	local pos = ply:GetEyeTraceNoCursor().HitPos;
	if (ply:GetPos():Distance(pos) > 255) then
		pos = ply:GetShootPos() + ply:GetAimVector() * 255;
	end
	local words = table.concat({...}, " "):sub(1,150):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	
	-- Create the money entity.
	local entity = ents.Create("cider_note");
	
	-- Set the amount and position of the money.
	entity:SetText(words);
	entity:SetPos(pos + Vector(0, 0, 5 ) );
	
	-- Spawn the money entity.
	entity:Spawn();
	cider.propprotection.PlayerMakePropOwner(ply, entity, true);	
	
	ply:AddCount("notes", entity);
	local index = entity:EntIndex()
	-- Add this to our undo table.
	undo.Create("Note");
		undo.SetPlayer(ply);
		undo.AddEntity(entity);
	undo.Finish();
	GM:Log(EVENT_EVENT, "%s wrote a note: %s", ply:Name(), words);
end, "Commands", "<text>", "Write a note at your target position.", true);

-- A command to change your job title
cider.command.add("job", "b", 0, function(ply, ...)
	local words = table.concat({...}, " "):sub(1,50):Trim();
	if (not words or words == "") then
		words = team.GetName(ply:Team());
	end
	ply._Job = words;
	ply:SetNWString("Job", ply._Job);
	ply:Notify("You have changed your job title to '" .. words .. "'.");
	GM:Log(EVENT_EVENT, "%s changed " .. ply._GenderWord .. " job text to %q.", ply:Name(), words);
end, "Commands", "[text]", "Change your job title or reset it.", true);

-- A command to change your clan.
cider.command.add("clan", "b", 0, function(ply, ...)
	local words = table.concat({...}, " "):sub(1,43):Trim();
	if (not words or words == "quit" or words == "none") then
		words = "";
	end
	ply.cider._Clan = words;
	ply:SetNWString("Clan", words);
	GM:Log(EVENT_EVENT, "%s set their clan to %q.", ply:Name(), words);
	if (words == "") then
		ply:Notify("You have unset your clan", 0);
	else
		ply:Notify("You have set your clan to '" .. words .. "'.", 0);
	end
end, "Commands", "[text|quit|none]", "Change your clan or quit your current one.",true);

-- A command to change your gender.
cider.command.add("gender", "b", 1, function(ply, gender)
	gender = string.lower(gender);
	if (gender ~= "male" and gender ~= "female") then
		return false, "Invalid gender specified.";
	elseif (string.lower(ply._Gender) == gender) then
		return false, "You are already " .. gender .. "!";
	elseif (gender == "male") then
		ply._NextSpawnGender = "Male";
		ply._NextSpawnGenderWord = "his";
	else
		ply._NextSpawnGender = "Female";
		ply._NextSpawnGenderWord = "her";
	end
	ply:Notify("You will be " .. gender .. " next time you spawn.", 0);
	GM:Log(EVENT_EVENT, "%s set " .. ply._NextSpawnGenderWord .. " gender to " .. gender .. ".", ply:Name());
end, "Menu Handlers", "<male|female>", "Change your gender.", true);

-- A command to yell in character.
cider.command.add("y", "b", 1, function(ply, ...)
	local words = table.concat({...}, " "):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	
	-- Print a message to other players within a radius of the player's position.
	cider.chatBox.addInRadius(ply, "yell", words, ply:GetPos(), GM.Config["Talk Radius"] * 2);
end, "Commands", "<text>", "Yell to players near you.", true);

-- A command to do 'me' style text.
cider.command.add("me", "b", 1, function(ply, ...)
	local words = table.concat({...}, " "):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	ply:Emote(words);
end, "Commands", "<text>", "e.g: <your name> cries a river.", true);

-- A command to whisper in character.
cider.command.add("w", "b", 1, function(ply, ...)
	local words = table.concat({...}, " "):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	
	-- Print a message to other players within a radius of the player's position.
	cider.chatBox.addInRadius(ply, "whisper", words, ply:GetPos(), GM.Config["Talk Radius"] / 2);
end, "Commands", "<text>", "Whisper to players near you.", true);

-- A command to send an advert to all players.
cider.command.add("advert", "b", 1, function(ply, ...)
	if (ply._NextAdvert > CurTime()) then
		local timeleft = math.ceil(ply._NextAdvert - CurTime());
		if (timeleft > 60) then
			timeleft = string.ToMinutesSeconds(timeleft).." minutes"
		else
			timeleft = timeleft.." second(s)"
		end
		return false,"You must wait "..timeleft.." before using advert again!";
	elseif (not ply:CanAfford(GM.Config['Advert Cost'])) then
		return false, "You need another $" .. (GM.Config['Advert Cost'] - ply.cider._Money) .. "!";
	end
	local words = table.concat({...}, " "):Trim();
	if (not words or words == "") then
		return false, "You must specify a message!";
	end
	ply._NextAdvert = CurTime() + GM.Config["Advert Timeout"]
	-- Print a message to all players.
	cider.chatBox.add(nil, ply, "advert", words);
	ply:GiveMoney(-GM.Config["Advert Cost"]);
	GM:Log(EVENT_EVENT, "%s advertised %q",ply:Name(),words)
end, "Commands", "<text>", "Send an advert to all players ($"..GM.Config["Advert Cost"]..").", true);

-- A command to change your team.
cider.command.add("team", "b", 1, function(ply, identifier)
	local teamdata = team.Get(identifier);
	if (not teamdata) then
		return false, "Invalid team!";
	end
	local teamid = teamdata.TeamID;
	if (teamid == ply:Team()) then
		return false, "You are already that team!";
	elseif (teamdata.SizeLimit ~= 0 and team.NumPlayers(teamid) > teamdata.SizeLimit) then
		return false, "That team is full!";
	elseif (not gamemode.Call("PlayerCanJoinTeam", ply, teamid)) then
		return false;
	end
	ply:HolsterAll();
	return ply:JoinTeam(teamid);
end, "Menu Handlers", "<team>", "Change your team.", true);

-- A command to perform inventory action on an item.
cider.command.add("inventory", "b", 2, function(ply, id, action, amount)
	id = string.lower(id);
	action = string.lower(action);
	local item = GM.Items[id];
	if (not item) then
		return false, "Invalid item specified.";
	end
	local holding = ply.cider._Inventory[id]
	if (not holding or holding < 1) then
		return false, "You do not own any " .. item.Plural .."!";
	elseif (action == "destroy") then
		item:Destroy(ply);
	-- START CAR ACTIONS (TODO: find some other way of doing this?)
	elseif (action == "pickup") then
		item:Pickup(ply);
	elseif (action == "sell") then
		item:Sell(ply);
	-- END CAR ACTIONS
	elseif (action == "drop") then
		if (amount == "all") then
			amount = holding;
		else
			amount = math.floor(tonumber(amount) or 1);
		end
		amount = math.min(amount, holding);
		if (amount < 1) then
			return false, "Invalid amount!";
		end
		local pos = ply:GetEyeTraceNoCursor().HitPos;
		if (ply:GetPos():Distance(pos) > 255) then
			pos = ply:GetShootPos() + ply:GetAimVector() * 255;
		end
		return item:Drop(ply, pos, amount);
	elseif (action == "use") then
		local time = CurTime();
		if (not ply:IsAdmin()) then -- Admins bypass the item timer
			if ((ply._NextUseItem or 0) > time) then
				return false, "You cannot use another item for " .. math.ceil(ply._NextUseItem - time) .. " more seconds!";
			elseif ((ply._NextUse[id] or 0) > time) then
				return false, "You cannot use another " .. item.Name .. " for " .. math.ceil(ply._NextUse[id]) .. " more seconds!";
			end
		end if (ply:InVehicle() and item.NoVehicles) then
			return false, "You cannot use that item while in a vehicle!";
		elseif (not gamemode.Call("PlayerCanUseItem", ply, id)) then
			return false;
		end if (item.Weapon) then
			ply._NextHolsterWeapon = CurTime() + 5;
		end
		ply._NextUseItem = time + GM.Config['Item Timer'];
		ply._NextUse[id] = time + GM.Config['Item Timer (S)'];
		return item:Use(ply);
	else
		return false, "Invalid action specified!"
	end
end, "Menu Handlers", "<item> <destroy|drop|use> [amount]", "Perform an inventory action on an item.", true);

local function containerHandler(ply, item, action, number)
	local container = ply:GetEyeTraceNoCursor().Entity
	if not (ValidEntity(container) and cider.container.isContainer(container) and ply:GetPos():Distance( ply:GetEyeTraceNoCursor().HitPos ) <= 128) then
		return false,"That is not a valid container!"
	elseif not gamemode.Call("PlayerCanUseContainer",ply,container) then
		return false,"You cannot use that container!"
	end
	item = item:lower()
	action = action:lower()
	if (action ~= "put" and action ~= "take") then
		return false, "Invalid option: "..action.."!";
	end
	if (number == "all") then
		number = 9999;
	end
	number = math.floor(tonumber(number) or 1);
	if (number < 1) then
		return false, "Invalid amount!";
	elseif not GM.Items[item]  then
		return false,"Invalid item!"
	end
	local cInventory,io,filter = cider.container.getContents(container,ply,true)
	local pInventory = ply.cider._Inventory
	if action == "put" then
		local amount = (item == "money") and ply.cider._Money or pInventory[item]
		if (not amount) then
			return false, "You do not have any of this item!";
		end
		number = math.min(number, amount);
	else
		local amount = cInventory[item]
		if (not amount) then
			return false, "There is none of that item in here!";
		elseif (amount < 0) then
			return false, "You cannot take that item out!";
		end
		number = math.min(number, amount);
	end
	if filter and action == "put" and not filter[item] then
		return false, "You cannot put that item in!"
	end
	do
		local action = action == "put" and CAN_PUT or CAN_TAKE
		if not( action & io == action) then
			return false,"You cannot do that!"
		end
	end
	if number == 0 then return false, "Invalid amount!" end
	if action == "take" then number = -number end
	return cider.container.update(container,item,number,nil,ply)
end

cider.command.add("container", "b", 2, function(ply, ...)
	-- I use a handler because returning a value is so much neater than a pyramid of ifs.
	local res,msg = containerHandler(ply, ...)
	if res then
		local entity = ply:GetEyeTraceNoCursor().Entity
		local contents,io,filter = cider.container.getContents(entity,ply,true)
		local tab = {
			contents = contents,
			meta = {
				io = io,
				filter = filter, -- Only these can be put in here, if nil then ignore, but empty means nothing.
				size = cider.container.getLimit(entity), -- Max space for the container
				entindex = entity:EntIndex(), -- You'll probably want it for something
				name = cider.container.getName(entity) or "Container"
			}
		}
		datastream.StreamToClients( ply, "cider_Container_Update", tab );
	else
		SendUserMessage("cider_CloseContainerMenu",ply);
	end
	return res,msg
end, "Menu Handlers", "<item> <put|take> <amount>", "Put or take an item from a container", true);


do --isolate vars
	local function conditional(ply,pos)
		return ply:IsValid() and ply:GetPos() == pos;
	end
	local function success(ply,_,class)
		if (not ply:IsValid()) then return end
		ply._Equipping = false;
		local s,f = cider.inventory.update(ply, class, 1);
		if (not s) then
			ply:Emote(GM.Config["Weapon Timers"]["Equip Message"]["Abort"]:format(ply._GenderWord));
			if (f and f ~= "") then
				ply:Notify(f, 1);
			end
			return
		end
		ply:StripWeapon(class);
		GM:Log(EVENT_EVENT, "%s holstered "..ply._GenderWord.." %s.",ply:Name(),GM.Items[class].Name);
		ply:SelectWeapon("cider_hands");
		local weptype = GM.Items[class].WeaponType
		if weptype then
			ply:Emote(GM.Config["Weapon Timers"]["Equip Message"]["Plugh"]:format( weptype, ply._GenderWord ));
		end
	end

	local function failure(ply)
		if (not ply:IsValid()) then return end
		ply:Emote(GM.Config["Weapon Timers"]["Equip Message"]["Abort"]:format(ply._GenderWord));
		ply._Equipping = false;
		SendUserMessage("MS Equippr FAIL", ply);
	end

	-- A command to holster your current weapon.
	cider.command.add("holster", "b", 0, function(ply)
		local weapon = ply:GetActiveWeapon();
		
		-- Check if they can holster another weapon yet.
		if ( !ply:IsAdmin() and ply._NextHolsterWeapon and ply._NextHolsterWeapon > CurTime() ) then
			return false, "You cannot holster this weapon for "..math.ceil( ply._NextHolsterWeapon - CurTime() ).." second(s)!";
		else
			ply._NextHolsterWeapon = CurTime() + 2;
		end
		
		-- Check if the weapon is a valid entity.
		if not ( ValidEntity(weapon) and GM.Items[weapon:GetClass()] ) then
			return false, "This is not a valid weapon!";
		end
		local class = weapon:GetClass();
		if not ( gamemode.Call("PlayerCanHolster", ply, class) ) then
			return false
		end

		ply._Equipping = ply:GetPos()
		local delay = GM.Config["Weapon Timers"]["equiptime"][GM.Items[class].WeaponType or -1] or 0
		if not (delay and delay > 0)then
			success(ply,_,class);
			return true
		end
		umsg.Start("MS Equippr", ply)
		umsg.Short(delay);
		umsg.Bool(false);
		umsg.End();
		timer.Conditional(ply:UniqueID().." holster", delay, conditional, success, failure, ply, ply:GetPos(), class);
		ply:Emote(GM.Config["Weapon Timers"]["Equip Message"]["Start"]:format(ply._GenderWord));
	end, "Commands", nil, "Holster your current weapon.");
end

-- A command to drop your current weapon.
cider.command.add("drop", "b", 0, function()
	return false, "Use /holster instead.";
end, "Commands", nil, "Put in for DarkRP players. Do not use.");

-- A command to perform an action on a door.
cider.command.add("door", "b", 1, function(ply, action, ...)
	local tr = ply:GetEyeTraceNoCursor();
	local ent = tr.Entity
	action = action:lower();
	if (not (IsValid(ent) and ent:IsDoor() and ply:GetPos():Distance(tr.HitPos) < 128)) then
		return false, "You must be looking at a door!";
	elseif (ent:IsOwned()) then
		if (action == "purchase") then
			return false, "Someone else owns this door!";
		elseif (action == "sell") then
			if (ent:GetOwner() ~= ply or ent._Unsellable) then
				return false, "You cannot sell this door!";
			end
			GM:Log(EVENT_EVENT, "%s sold " .. ply._GenderWord .. " door %s.", ply:Name(), ent:GetDoorName());
			ply:TakeDoor(ent);
			return true;
		end
		return false, "Invalid action!";
	elseif (action ~= "purchase") then
		return false, "Invaild action specified!";
	elseif (not (gamemode.Call("PlayerCanOwnDoor", ply, ent) and ply:CheckLimit("doors"))) then
		return false;
	end
	local cost = GM.Config["Door Cost"];
	local can, result = ply:CanAfford(cost);
	if (not can) then
		return false,"You need another $" .. result .. " to buy that door!";
	end
	ply:GiveMoney(-cost);
	
	local name = table.concat({...}, " "):sub(1, 24);
	-- Get the name from the arguments.
	local lower = name:lower();
	if (lower:find("for sale") or lower:find("f2") or lower == "nobody") then
		name = ply:Name();
	end
	ply:GiveDoor(ent, name);
	cider.propprotection.ClearSpawner(ent);
	GM:Log(EVENT_EVENT, "%s bought a door called %q.",ply:Name(),ent:GetDoorName())
end, "Menu Handlers", "<purchase|sell>", "Perform an action on the door you're looking at.", 1);

local function enthandle(ply, ent, action, ...)
	action = action:lower();
	if (action == "name") then
		if (not gamemode.Call("PlayerCanSetEntName", ply, ent)) then
			return false, "You cannot set this entity's name";
		end
		local name = table.concat({...}, " "):sub(1, 24):Trim();
		local lower = name:lower();
		if (lower:find("for sale") or lower:find("f2") or lower == "nobody") then
			name = ply:Name();
		end
		local oldname = ent:GetDisplayName()
		ent:SetDisplayName(name)
		GM:Log(EVENT_ENTITY, "%s changed " .. ply._GenderWord .. " %s's name from %q to %q.", ply:Name(), ent._isDoor and "door" or ent:GetNWString("Name","entity"), oldname, name);
		return true;
	elseif (not (action == "give" or action == "take")) then
		return false, "Invalid Action!";
	end
	local kind, id = ...;
	id = tonumber(id);
	if (not (kind and id)) then
		return false, "Malformed access parameters";
	end
	kind = kind:lower();
	local target, name;
	if (kind == "player") then
		target = player.Get(id)
		name = target:Name()
	elseif (kind == "team") then
		target = team.Get(id)
		name = target.Name
	elseif (kind == "gang") then
		target = GM:GetGang(id);
		name = target.Name;
	elseif (kind == "group") then
		target = GM:GetGroup(id);
		name = target.Name;
	end
	if (not target) then
		return false, "Invalid target!";
	end
	local word
	if action == "give" then
		if kind == "player" then
			ent:GiveAccessToPlayer(target);
		elseif kind == "team" then
			ent:GiveAccessToTeam(target);
		elseif kind == "gang" then
			ent:GiveAccessToGang(target);
		elseif kind == "group" then
			ent:GiveAccessToGroup(target);
		end
		word = "%s gave %s access to " .. ply._GenderWord .. " %s.";
	else
		if kind == "player" then
			ent:TakeAccessFromPlayer(target);
		elseif kind == "team" then
			ent:TakeAccessFromTeam(target);
		elseif kind == "gang" then
			ent:TakeAccessFromGang(target);
		elseif kind == "group" then
			ent:TakeAccessFromGroup(target);
		end
		word = "%s removed %s's access from " .. ply._GenderWord .. " %s.";
	end
	GM:Log(EVENT_ENTITY, word, ply:Name(), name, ent._isDoor and "door" or ent:GetNWString("Name","entity"));
end
-- A command to perform an action on an ent
cider.command.add("entity", "b", 2, function(ply, action, ...)
	local tr = ply:GetEyeTraceNoCursor();
	local ent = tr.Entity
	action = string.lower(action);
	if (not (IsValid(ent) and ent:IsOwnable() and ply:GetPos():Distance(tr.HitPos) < 128)) then
		return false, "You must be looking at an entity!";
	elseif (ent:GetOwner() ~= ply) then
		return false, "You do not own this!";
	end
	local res, err = enthandle(ply, ent, action, ...);
	local tab = {
		title = ent:GetPossessiveName() .. " " .. (ent._isDoor and "door" or ent:GetNWString("Name","entity"));
		access = ent._Owner.access;
		owner = ent._Owner.owner;
		owned = {
			sellable = (ent._isDoor and not ent._UnSellable) or nil;
			name = gamemode.Call("PlayerCanSetEntName", ply, ent) and ent:GetDisplayName() or nil;
		};
	};
	datastream.StreamToClients(ply, "Access Menu Update", tab);
	return res, err;
end, "Menu Handlers", "<give|take> <ID> <type> or <name> <mynamehere>", "Perform an action on the entity you're looking at", 1);

-- A command to manufacture an item.
cider.command.add("manufacture", "b", 1, function(ply, itemid)
	local item = GM:GetItem(itemid);
	if (not item) then
		return false, "No such item '" .. itemid .. "'!";
	elseif (not gamemode.Call("PlayerCanManufactureCategory", ply, item.Category)) then
		return false, ply:GetTeam().Name .. "s cannot manufacture "..GM:GetCategory(item.Category).Name.."!";
	elseif (not gamemode.Call("PlayerCanManufactureItem", ply, item)) then
		return false;
	elseif (not ply:IsAdmin() and (ply.NextManufactureItem or 0) > CurTime()) then
		return false, "You cannot manufacture another item for "..math.ceil( ply._NextManufactureItem - CurTime() ).." second(s)!";		
	end
	local amt = item.Batch;
	local price = item.Cost * amt;
	local can, req = ply:CanAfford(price);
	if (not can) then
		return false, "You need another $" .. req .. " to afford that!";
	end
	ply:GiveMoney(-price);
	ply.NextManufactureItem = CurTime() + 5 * amt;
	
	local tr = ply:GetEyeTraceNoCursor();
	local ent = item:Make(tr.HitPos + Vector(0,0,16), amt);
	if (item.onManufacture) then
		item:onManufacture(ply, ent, amt);
	end
	cider.propprotection.GiveToWorld(ent);
	local words = "";
	if (amt > 1) then
		words = amt .. " " .. item.Plural;
	else
		words = "a " .. item.Name;
	end
	ply:Notify("You manufactured " .. words .. ".");
	GM:Log(EVENT_EVENT, "%s manufactured %s.", ply:Name(), text);
end, "Menu Handlers", "<item>", "Manufacture an item (usually a shipment).", true);

-- A command to warrant a player.
cider.command.add("warrant", "b", 1, function(ply, arguments)
	local target = player.Get(arguments[1])
	
	-- Get the class of the warrant.
	local class = string.lower(arguments[2] or "");
	
	-- Check if a second argument was specified.
	if (class == "search" or class == "arrest") then
		if (target) then
			if ( target:Alive() ) then
				if (target._Warranted ~= class) then
					if (!target.cider._Arrested) then
						if (CurTime() > target._CannotBeWarranted) then
							if ( hook.Call("PlayerCanWarrant",GAMEMODE, ply, target, class) ) then
								hook.Call("PlayerWarrant",GAMEMODE, ply, target, class);
								
								-- Warrant the player.
								target:Warrant(class);
							end
						else
							return false, target:Name().." has only just spawned!";
						end
					else
						return false, target:Name().." is already arrested!";
					end
				else
					if (class == "search") then
						return false, target:Name().." is already warranted for a search!";
					elseif (class == "arrest") then
						return false, target:Name().." is already warranted for an arrest!";
					end
				end
			else
				return false, target:Name().." is dead and cannot be warranted!";
			end
		else
			return false, arguments[1].." is not a valid player!"
		end
	else
		return false, "Invalid warrant type. Use 'search' or 'arrest'"
	end
end, "Commands", "<player> <search|arrest>", "Warrant a player.");

-- A command to unwarrant a player.
cider.command.add("unwarrant", "b", 1, function(ply, arguments)
	local target = player.Get(arguments[1])
	
	-- Check to see if we got a valid target.
	if (target) then
		if (target._Warranted) then
			if ( hook.Call("PlayerCanUnwarrant",GAMEMODE, ply, target) ) then
				hook.Call("PlayerUnwarrant",GAMEMODE, ply, target);
				
				-- Warrant the player.
				target:UnWarrant();
			end
		else
			return false, target:Name().." does not have a warrant!"
		end
	else
		return false, arguments[1].." is not a valid player!"
	end
end, "Commands", "<player>", "Unwarrant a player.");

do -- Reduce the upvalues poluting the area.
	local function conditional(ply, pos)
		return IsValid(ply) and ply:GetPos() == pos;
	end

	local function success(ply)
		ply:KnockOut();
		GM:Log(EVENT_EVENT, "%s went to sleep.", ply:Name());
		ply._Sleeping = true;
		ply:SetCSVar(CLASS_BOOL,"_Sleeping", true); -- Make sure it happens NOW not in 0.01s time.
		ply:Emote("slumps to the floor, asleep.");
		ply:SetCSVar(CLASS_LONG, "_GoToSleepTime", 0);
		SendUserMessage("MS Wakeup Call", ply, true);
	end

	local function failure(ply)
		ply:SetCSVar(CLASS_LONG, "_GoToSleepTime", 0);
	end
	-- A command to sleep or wake up.
	cider.command.add("sleep", "b", 0, function(ply)
		if (ply._Sleeping and ply:KnockedOut()) then
			return ply:WakeUp();
		end
		ply:SetCSVar(CLASS_LONG, "_GoToSleepTime", CurTime() + GM.Config["Sleep Waiting Time"]);
		timer.Conditional(ply:UniqueID().." sleeping timer", GM.Config["Sleep Waiting Time"], conditional, success, failure, ply, ply:GetPos());
	end, "Commands", nil, "Go to sleep or wake up from sleeping.");
end
-- A command to send a message to all players on the same team.
cider.command.add("radio", "b", 1, function(ply, arguments)
	local text = table.concat(arguments, " ");
	
	-- Say a message as a radio broadcast.
	ply:SayRadio(text);
end, "Commands", "<text>", "Send a message to all players on your team.");

cider.command.add("trip", "b", 0, function(ply,arguments)
	if ply:GetVelocity() == Vector(0,0,0) then
		return false,"You must be moving to trip!"
	elseif ply:InVehicle() then
		return false,"There is nothing to trip on in here!";
	end
	ply:KnockOut(5)
	ply._Tripped = true
	cider.chatBox.addInRadius(ply, "me", "trips and falls heavily to the ground.", ply:GetPos(), GM.Config["Talk Radius"]);
	GM:Log(EVENT_EVENT,"%s fell over.",ply:GetName())
end, "Commands", "", [[Fall over while walking. (bind key "say /trip")]]);

cider.command.add("fallover", "b", 0, function(ply,arguments)
	if not (ply:KnockedOut() or ply:InVehicle()) then
		ply:KnockOut(5)
		ply._Tripped = true
		cider.chatBox.addInRadius(ply, "me", "slumps to the ground.", ply:GetPos(), GM.Config["Talk Radius"]);
		GM:Log(EVENT_EVENT,"%s fell over.",ply:GetName())
	end
end, "Commands", "", "Fall over.");
local function canmutiny(ply, victim)
	local pt, vt = ply:GetTeam(), victim:GetTeam();
	return pt.Group == vt.Group
	and    pt.Gang  == pt.Gang and pt.Gang
	and    vt.GroupLevel == GROUP_GANGBOSS;
end
cider.command.add("mutiny","b",1,function(ply, args)
	local victim = player.Get(args[1]);
	if (not IsPlayer(victim)) then
		return false, "No such player '" .. args[1] .. "'!";
	end
	if (not canmutiny(ply, victim)) then
		return false, "You cannot mutiny against this person!";
	end
	victim.depositions = victim.depositions or {};
	if (victim.depositions[ply]) then
		return false, "Your mutiny vote has alrady been counted!";
	end
	victim.depositions[ply] = true;
	i = 0;
	for ply in pairs(victim.depositions) do
		if (not (IsValid(ply) and canmutiny(ply, victim))) then
			victim.depositions[ply] = nil;
		else
			i = i + 1;
		end
	end
	local gang = ply:GetTeam().Gang
	local minimum = math.min( math.floor(
		(#GM:GetGangMembers(gang)) * GM.Config["Mutiny Percentage"]),
		GM.Config["Minimum to mutiny"]);
	GM:Log(EVENT_EVENT, "%s voted to mutiny against %s. Votes: %i / %i", ply:Name(), victim:Name(), i, minimum);
	if (i < minimum) then
		ply:Notify("Your vote has been counted, but you are not yet in the majority...");
		return;
	end
	player.NotifyAll(NOTIFY_CHAT, "%s was overthrown as leader of the %s!", victim:Name(), gang.Name);
	victim:Notify("Your gang has overthrown you!", nil, 1);
	victim:Demote();
end, "Commands","<player>","Try to start a mutiny against your leader")

-- A command to give Donator status to a player.
cider.command.add("donator", "s", 1, function(ply, arguments)
	local target = player.Get( arguments[1] )
	
	-- Calculate the days that the player will be given Donator status for.
	local days = math.ceil(tonumber( arguments[2] ) or 30);
	
	-- Check if we got a valid target.
	if not (target) then
		return false, arguments[1].." is not a valid player!"
	end
		target.cider._Donator = os.time() + (86400 * days);
		
		-- Give them their access and save their data.
		target:GiveAccess("tpew");
		target:SaveData();
		
		-- Give them the tool and the physics gun.
		target:Give("gmod_tool");
		target:Give("weapon_physgun");
		
		-- Set some Donator only player variables.
		target._SpawnTime = target._SpawnTime / 2;
		target._ArrestTime = target._ArrestTime / 2;
		target._KnockOutTime = target._KnockOutTime / 2;
		
		-- Print a message to all players about this player getting Donator status.
		player.NotifyAll(NOTIFY_CHAT, "%s has given Donator status to %s for %i day(s).", ply:Name(), target:Name(), days);
end, "Super Admin Commands", "<player> <days|none>", "Give Donator status to a player.");

-- A command to change your clan.
cider.command.add("details", "b", 0, function(ply, arguments)
	local text = table.concat(arguments, " ")
	--[[ Check the length of the arguments.
	if ( string.len(text) > 64 ) then
		return false,"Your details can be a maximum of 64 characters!"
	end--]]
	text = text:sub(1,64):Trim()
	if (text == "" or string.lower(text) == "none") then
		ply._Details = "";
		
		-- Print a message to the player.
		ply:Notify("You have set your details to nothing.");
		GM:Log(EVENT_EVENT, "%s changed "..ply._GenderWord.." details to %q.",ply:Name(),"nothing")
	else
		ply._Details = text;
		
		-- Print a message to the player.
		ply:Notify("You have changed your details to '"..text.."'.");
		GM:Log(EVENT_EVENT, "%s changed "..ply._GenderWord.." details to %q.",ply:Name(),text)
	end
	ply:SetNWString("Details", ply._Details);
end, "Commands", "<text|none>", "Change your details or make them blank.");


cider.command.add("action","b",1,function(ply,arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		return false,"You did not specify enough text!"
	end
	cider.chatBox.addInRadius(ply, "action", text, ply:GetPos(), GM.Config["Talk Radius"]);
end, "Commands", "<text>", "Add an environmental emote")

cider.command.add("globalaction","m",1,function(ply,arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		return false,"You did not specify enough text!"
	end
	cider.chatBox.add(nil,ply, "action", text);
end, "Moderator Commands", "<text>","Add a global environmental emote")

cider.command.add("ooc","b",1,function(ply,arguments)
	local text = table.concat(arguments," ")
	if not text or text == "" then return false,"wat" end
	if ( hook.Call("PlayerCanSayOOC",GAMEMODE, ply, text) ) then
		cider.chatBox.add(nil,ply, "ooc",text);
		--GM:Log(EVENT_TALKING,"(OOC) %s: %s",player:Name(),text)
	else
		return false
	end
end, "Commands", "<text>", "Say something out of character to everyone. (shortcut: //<text>)")

cider.command.add("looc","b",1,function(ply,arguments)
	local text = table.concat(arguments," ")
	if not text or text == "" then return false,"wat" end
	if ( hook.Call("PlayerCanSayLOOC",GAMEMODE, ply, text) ) then
		cider.chatBox.addInRadius(ply, "looc",text , ply:GetPos(), GM.Config["Talk Radius"]);
		--GM:Log(EVENT_TALKING,"(Local OOC) %s: %s",player:Name(),text)
	else
		return false
	end
end, "Commands", "<text>", "Say something out of character to the people around you. (shortcut: .//<text>)")


-- Set an ent's master
cider.command.add("setmaster","s",1,function(ply, masterID)
	local entity = ply:GetEyeTraceNoCursor().Entity
	local master = Entity(masterID)
	if not (ValidEntity(entity) and entity:IsOwnable()) then
		return false,"That is not a valid entity!"
	elseif not ((ValidEntity(master) and master:IsOwnable()) or masterID == 0) then
		return false,"That is not a valid entity ID!"
	end
	if masterID == 0 then
		master = NULL
		GM:Log(EVENT_ENTITY, "%s unset a %s's master",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
	else
		GM:Log(EVENT_ENTITY, "%s set a %s's master",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
	end
	entity:SetMaster(master)
	hook.Call("EntityMasterSet",GAMEMODE,entity,master)
end, "Super Admin Commands", "<ID of master|0>", "Set/Unset an ent's master",true)
-- Seal a door
cider.command.add("seal","s",0,function(ply,unseal)
	local entity = ply:GetEyeTraceNoCursor().Entity
	if not (ValidEntity(entity) and entity:IsOwnable()) then
		return false,"That is not a valid entity!"
	end
	if unseal then
		entity._Sealed = false
		
		if (entity:GetDTInt(3) & OBJ_SEALED == OBJ_SEALED) then
			entity:SetDTInt(3, entity:GetDTInt(3) -  OBJ_SEALED);
		end
		hook.Call("EntitySealed",GAMEMODE,entity,true)
		GM:Log(EVENT_ENTITY, "%s unsealed a %s,",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
	else
		entity._Sealed = true
		if (entity:GetDTInt(3) & OBJ_SEALED ~= OBJ_SEALED) then
			entity:SetDTInt(3, entity:GetDTInt(3) +  OBJ_SEALED);
		end
		hook.Call("EntitySealed",GAMEMODE,entity)
		GM:Log(EVENT_ENTITY, "%s sealed a %s,",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
	end
end, "Super Admin Commands", "[unseal]", "Seal/Unseal an entity so it cannot be used",true)

cider.command.add("setname","s",1,function(ply,arguments)
	local entity = ply:GetEyeTraceNoCursor().Entity
	if not (ValidEntity(entity) and entity:IsOwnable() and entity._isDoor) then
		return false,"That is not a valid door!"
	end
	local words = table.concat(arguments," "):Trim():sub(1,25)
	if not words or words == "" then
		words = ""
	end
	entity:SetNWString("Name",words)
	GM:Log(EVENT_ENTITY, "%s changed a door's name to %q.",ply:Name(),words)
	hook.Call("EntityNameSet",GAMEMODE,entity,words)
end, "Super Admin Commands", "<name>", "Set the name of a door")

cider.command.add("setowner","s",1,function(ply, kind, id)
	local ent = ply:GetEyeTraceNoCursor().Entity
	if (not (IsValid(ent) and ent:IsOwnable())) then
		return false, "You cannot set the owner of this!";
	end
	kind = string.lower(kind);
	-- Slavery
	ent = ent:GetMaster() or ent;
	if (kind == "none") then
		ent:ClearOwnershipData();
		GM:Log(EVENT_ENTITY, "%s wiped the ownership data on %s",
			ply:Name(), ent:GetNWString("Name", "an entity"));
		gamemode.Call("EntityOwnerSet", ent, nil)
		return;
	end
	-- Motherfucking miricles
	local kind_ = string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2);
	local func = GM["Get" .. kind_];
	if (not func) then
		return false, "Unknown kind '" .. kind .. "'!";
	end
	local target = func(GM, id);
	if (not target) then
		return false, "Unknown " .. kind .. " '" .. id .. "'";
	end
	ent["GiveTo" .. kind_](ent, target);
	local name = target.IsPlayer and target:Name() or target.Name;
	gamemode.Call("EntityOwnerSet", ent, target)
	GM:Log(EVENT_ENTITY, "%s gave ownership of %s to %s.", 
		ply:Name(), ent:GetNWString("Name", "an entity"), name);
end, "Super Admin Commands", "<player|team|group|gang|none> [identifier]", "Set the owner of a door", true);

cider.command.add("a","a",1,function(ply,arguments)
	local text = table.concat(arguments," ")
	if not text or text == "" then return false,"wat" end
	local rp = RecipientFilter()
	for _,ply in pairs(player.GetAll()) do
		if (ply:IsAdmin()) then
			rp:AddPlayer(ply)
		end
	end
	cider.chatBox.add(rp, ply, "achat", text);
end, "Admin Commands", "<text>", "Say something only to the other admins")

cider.command.add("m","m",1,function(ply,arguments)
	local text = table.concat(arguments," ")
	if not text or text == "" then return false,"wat" end
	local rp = RecipientFilter()
	for _,ply in pairs(player.GetAll()) do
		if (ply:IsModerator()) then
			rp:AddPlayer(ply)
		end
	end
	cider.chatBox.add(rp, ply, "mchat", text);
end, "Moderator Commands", "<text>", "Say something only to the other admins and moderators")
