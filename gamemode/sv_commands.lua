--[[
	~ Commands ~
	~ Applejack ~
--]]

GM:RegisterCommand{
	Command = "fuck";
	Help = "Free gratuitous swearing";
	function(ply)
		ply:Notify("FUCK!", NOTIFY_ERROR);
	end
}
--[[ ADMIN ABUSE COMMANDS ]]--
--[[
	These are only here at the insistance of my admins. They only apply to SuperAdmins, who probably can be trusted.
	If yours can't be trusted, delete the space between the [s as shown below.
--]]
--[ [<--Delete the space between these [s if you want to disable the abuse commands

-- Knock out one person for an optional amount of time. Will default to 5.
GM:RegisterCommand{
	Command     = "knockout";
	Access      = "s";
	Arguments   = "<victim> [time]";
	Types       = "Player Number";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Knock someone out. (Defaults to 5 seconds)";
	function(ply, victim, time)
		victim:KnockOut(time or 5);
		GM:Log(EVENT_EVENT, "%s knocked out %s", ply:Name(), victim:Name());
	end
};

-- Wake a player up
GM:RegisterCommand{
	Command     = "wakeup";
	Access      = "s";
	Arguments   = "<victim>";
	Types       = "Player";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Wake someone up";
	function(ply, victim)
		victim:WakeUp();
		GM:Log(EVENT_EVENT, "%s woke up %s", ply:Name(), victim:Name());
	end
};

local function knockoutfunct(tbl,tiem)
	local target = table.remove(tbl);
	if (IsValid(target) and target:Alive()) then
		target:HolsterAll();
		target:KnockOut(tiem);
	end
end
-- Knock out everyone for a specified time. (Try not to use)
GM:RegisterCommand{
	Command     = "knockoutall";
	Access      = "s";
	Arguments   = "[time]";
	Types       = "Number";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Knock everyoneone out. (Defaults to 5 seconds)";
	function(ply, time)
		local tbl = player.GetAll();
		player.NotifyAll(NOTIFY_GENERIC, "%s knocked everyone out .", ply:Name());
		timer.Create(ply:Name() .. " admin abuse knockout", 0.1, #tbl, knockoutfunct, tbl, time or 5);
	end
};

local function unknockoutfunct(tbl)
	local target = table.remove(tbl);
	if (IsValid(target)) then
		target:WakeUp();
	end
end
-- Wake everyone up
GM:RegisterCommand{
	Command     = "wakeupall";
	Access      = "s";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Wake everyone up";
	function(ply)
		local tbl = player.GetAll();
		player.NotifyAll(NOTIFY_GENERIC, "%s woke everyone up.", ply:Name());
		timer.Create(ply:Name() .. " admin abuse unknockout", 0.1, #tbl, unknockoutfunct, tbl);
	end
};

-- Tie a player up
GM:RegisterCommand{
	Command     = "tie";
	Access      = "s";
	Arguments   = "<victim>";
	Types       = "Player";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Tie someone up";
	function(ply, victim)
		victim:TieUp();
		GM:Log(EVENT_EVENT, "%s tied up %s", ply:Name(), victim:Name());
	end
};

GM:RegisterCommand{
	Command     = "untie";
	Access      = "s";
	Arguments   = "<victim>";
	Types       = "Player";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Untie someone";
	function(ply, victim)
		victim:UnTie();
		GM:Log(EVENT_EVENT, "%s untied %s", ply:Name(), victim:Name());
	end
};

-- There were '(un)tieall' commands here but they were removed.

-- Respawn a player completely
GM:RegisterCommand{
	Command     = "spawn";
	Access      = "s";
	Arguments   = "<victim>";
	Types       = "Player";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Instantly repsawn someone.";
	function(ply, victim)
		victim:Spawn();
		GM:Log(EVENT_EVENT, "%s respawned %s", ply:Name(), victim:Name());
	end
};

-- Arrest a player with optional arrest time
GM:RegisterCommand{
	Command     = "arrest";
	Access      = "s";
	Arguments   = "<victim> [time]";
	Types       = "Player Number";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Arrest someone. Optionally define how long they're arrested for.";
	function(ply, victim, time)
		victim:Arrest(time);
		GM:Log(EVENT_EVENT, "%s arrested %s", ply:Name(), victim:Name());
	end
};

-- Unarrest a player
GM:RegisterCommand{
	Command     = "unarrest";
	Access      = "s";
	Arguments   = "<victim>";
	Types       = "Player";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Unarrest someone.";
	function(ply, victim)
		victim:UnArrest();
		GM:Log(EVENT_EVENT, "%s unarrested %s", ply:Name(), victim:Name());
	end
};

-- Give a player an instant warrant with optional length
GM:RegisterCommand{
	Command     = "awarrant";
	Access      = "s";
	Arguments   = "<victim> <arrest|search> [time]";
	Types       = "Player Phrase Number";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Instantly give a player a warrant, ignoring game mechanics. Optionally give it a length.";
	function(ply, victim, kind, time)
		GM:Log(EVENT_EVENT,"%s gave %s a %s warrant for %s seconds", ply:Name(), victim:Name(), kind, time or "default");
		victim:Warrant(kind, time);
	end
};

-- Give a player a named SWep/HL2 gun
GM:RegisterCommand{
	Command     = "give";
	Access      = "s";
	Arguments   = "<victim> <class>";
	Types       = "Player String";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Give someone a weapon by classname, ie cider_baton";
	function(ply, victim, kind)
		if (not IsValid(victim:Give(kind))) then
			return false, "Invalid weapon '"..kind.."'!";
		end
		GM:Log(EVENT_EVENT, "%s gave %s a %s", ply:Name(), victim:Name(), kind);
	end
};

-- give a player some ammo
GM:RegisterCommand{
	Command     = "giveammo";
	Access      = "s";
	Arguments   = "<victim> <class> [amount]";
	Types       = "Player String Number";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Give someone ammo by classname, ie smg1_grenade";
	function(ply, victim, kind, amount)
		amount = amount or 20
		victim:GiveAmmo(amount, kind);
		GM:Log(EVENT_EVENT, "%s gave %s %s %s ammo", ply:Name(), victim:Name(), amount, kind);
	end
};

-- Give or take items away from players.
GM:RegisterCommand{
	Command     = "giveitem";
	Access      = "s";
	Arguments   = "<victim> <item> [amount] [force]";
	Types       = "Player String Number Bool";
	Category    = "SuperAdmin Abuse Commands";
	Help        = "Give someone an item. Use negative numbers to remove items.";
	function(ply, victim, name, amount, force)
		amount = amount or 1;
		force  = force or false;
		local item = GM:GetItem(name);
		if (not item) then
			return false, "Invalid item '"..name.."'!";
		end
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
		GM:Log(EVENT_PUBLICEVENT, "%s gave %s %s %s.", ply:Name(), person, amount, name);
	end
};

--]
--[[
	The following 'abuse' commands apply to all admins.
	If you do not want them, do as above.
--]]

--[ [ <-- Space to remove.

-- Set a player to a particular team (ignoring all restrictions like team size)
GM:RegisterCommand{
	Command     = "setteam";
	Access      = "a";
	Arguments   = "<victim> <team>";
	Types       = "Player String";
	Category    = "Admin Abuse Commands";
	Help        = "Set someone to a particular team, ignoring all restirctions.";
	function(ply, victim, target)
		local tdata = team.Get(target);
		if (not tdata) then
			return false, "Invalid team '"..targetteam.."'!";
		end
		victim:JoinTeam(tdata.TeamID);
		GM:Log(EVENT_EVENT,"%s set %s's team to %q", ply:Name(), victim:Name(), tdata.Name);
	end
};


GM:RegisterCommand{
	Command     = "invisible";
	Access      = "a";
	Arguments   = "[victim]";
	Types       = "Player";
	Category    = "Admin Abuse Commands";
	Help        = "Toggle the invisibility status of someone";
	function(ply, victim)
		if (not victim) then
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
	end
};

GM:RegisterCommand{
	Command     = "setmodel";
	Access      = "a";
	Arguments   = "<victim> <model>";
	Types       = "Player String";
	Category    = "Admin Abuse Commands";
	Help        = "Temporarily change someone's playermodel.";
	function(ply, victim, model)
		if (not util.IsValidModel(model)) then
			return false, "Invalid model!";
		end
		victim:SetModel(model);
		GM:Log(EVENT_EVENT,"%s set %s's model to %q", ply:Name(), victim:Name(), model);
	end
};

GM:RegisterCommand{
	Command     = "notify";
	Access      = "a";
	Arguments   = "<victim> <chat|drip|0|error|1|undo|2|bell|3> <notification>";
	Types       = "Player Phrase ...";
	Category    = "Admin Abuse Commands";
	Help        = "Send someone a notification via the in-game system";
	function(ply, victim, level, words)
		if (level == "drip") then
			level = 0;
		elseif (level == "error") then
			level = 1;
		elseif (level == "undo") then
			level = 2;
		elseif (level == "bell") then
			level = 3;
		else
			level = tonumber(level);
		end
		victim:Notify(words, level);
		GM:Log(EVENT_EVENT, "%s sent %s a level %s notification saying %q", ply:Name(), victim:Name(), level or "chat", words);
	end
};

GM:RegisterCommand{
	Command     = "notifyall";
	Access      = "a";
	Arguments   = "<chat|drip|0|error|1|undo|2|bell|3> <notification>";
	Types       = "Phrase ...";
	Category    = "Admin Abuse Commands";
	Help        = "Send everyone a notification via the in-game system";
	function(ply, victim, level, words)
		if (level == "drip") then
			level = 0;
		elseif (level == "error") then
			level = 1;
		elseif (level == "undo") then
			level = 2;
		elseif (level == "bell") then
			level = 3;
		else
			level = tonumber(level);
		end
		player.NotifyAll(level, "%s", words); -- Feeelthy hack to prevent unwanted stacking in the pooled string table.
		GM:Log(EVENT_PUBLICEVENT, "%s sent %s a level %s notification saying %q", ply:Name(), "everyone", level or "chat", words);
	end
};
--]]
--[[ END OF ADMIN ABUSE COMMANDS ]]--



GM:RegisterCommand{
	Command     = "giveaccess";
	Access      = "s";
	Arguments   = "<target> <flags>";
	Types       = "Player String";
	Help        = "Give someone extra access flags";
	function(ply, victim, flags)
		flags:gsub("[asm%s]", "");
		if (flags == "") then
			return false;
		end
		victim:GiveAccess(flags);
		player.NotifyAll(NOTIFY_CHAT, "%s gave %s access to the %q flag" .. (flags:len() > 1 and "s" or ""), ply:Name(), victim:Name(), flags);
	end
};

-- A command to take access from a pla
GM:RegisterCommand{
	Command     = "takeaccess";
	Access      = "s";
	Arguments   = "<target> <flags>";
	Types       = "Player String";
	Help        = "Remove someone's extra access flags";
	function(ply, victim, flags)
		flags:gsub("[asm%s]", "");
		if (flags == "") then
			return false;
		end
		victim:TakeAccess(flags);
		player.NotifyAll(NOTIFY_CHAT, "%s removed %s's access to the %q flag" .. (flags:len() > 1 and "s" or ""), ply:Name(), victim:Name(), flags);
	end
};

GM:RegisterCommand{
	Command      = "restartmap";
	Access      = "a";
	Help        = "Instantly do a soft restart of the server";
	function(ply)
		for _, pl in pairs(player.GetAll()) do
			pl:HolsterAll();
			pl:SaveData();
		end
		player.NotifyAll(NOTIFY_CHAT, "%s restarted the map!", ply:Name());
		game.ConsoleCommand("changelevel "..game.GetMap().."\n");
	end
};

local function getnamething(kind, thing)
	thing = string.lower(thing);
	if kind == "team" then
	-- Team blacklist
		local team = team.Get(thing)
		if      not team            then return false,thing.." is not a valid team!"
		elseif  not team.Blacklist  then return false, team.Name.." isn't blacklistable!"
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
		return cat.Name, cat.UniqueID;
	elseif kind == "cmd" then
	-- Command blacklist
		local cmd = GM.Commands[thing]
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
GM:RegisterCommand{
	Command     = "blacklist";
	Access      = "m";
	Arguments   = "<victim> <team|item|cat|cmd> <thing> <time> <reason>";
	Types       = "Player Phrase String Number ...";
	Help        = "Blacklist a player from doing something.";
	function(ply, victim, kind, thing, time, reason)
		if (victim:IsModerator()) then
			if (ply:IsSuperAdmin()) then
				-- Do nothing, just dealing with ranks.
			elseif (ply:IsAdmin()) then
				if (victim:IsSuperAdmin()) then
					return false, "Watch it, you!";
				elseif (victim:IsAdmin()) then
					return false, "You can't blacklist other admins!";
				end
			elseif (ply:IsModerator()) then
				if (victim:IsSuperAdmin()) then
					return false, "Oi, who do you think you are? :X";
				else
					return false, "You cannot blacklist other members of the administration team!";
				end
			end
		end
		if (time < 1) then
			return false, "You cannot blacklist for less than a minute!";
		elseif ((time > 10080 and not ply:IsSuperAdmin()) or (time > 1440 and not ply:IsAdmin())) then
			return false, "You cannot blacklist for that long!"
		end
		reason = string.sub(reason, 1, 65)
		reason = string.Trim(reason);
		if (reason:len() < 5 and not ply:IsSuperAdmin()) then
			return false, "You must specify a longer reason!";
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
	end
};

GM:RegisterCommand{
	Command     = "unblacklist";
	Access      = "m";
	Arguments   = "<target> <team|item|cat|cmd> <thing>";
	Types       = "Player Phrase String";
	Help        = "Unblacklist a player so they can do something.";
	function(ply, victim, kind, thing)
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
	end
};

GM:RegisterCommand{
	Command     = "blacklistlist";
	Access      = "m";
	Arguments   = "<target>";
	Types       = "Player";
	Help        = "Find out what a player's blacklisted from (in your console)";
	function(ply, victim)
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
			for _,t in pairs(printtable) do
				a(b,c, "-----------------------------------[ "..string.format("%-4s",t[1]).." ]------------------------------------");
				for _,t in pairs(t[2]) do
					a(b,c,w:format(t[1], t[2], t[3], t[4]));
				end
			end
		-- *sigh*
		ply:Notify("Blacklist details have been printed to your console.",0);
	end
};

-- A command to demote a player.
GM:RegisterCommand{
	Command     = "demote";
	Arguments   = "<victim> <reason>";
	Types       = "Player ...";
	Help        = "Demote a player from their current job";
	function(ply, victim, reason)
		reason = string.sub(reason, 1, 65)
		reason = string.Trim(reason);
		if (reason:len() < 5 and not ply:IsSuperAdmin()) then
			return false, "You must specify a longer reason!";
		end
		local res, msg = gamemode.Call("PlayerCanDemote", ply, victim);
		if (not res) then
			return false, msg;
		end
		local tid = victim:Team();
		victim:Demote();
		player.NotifyAll(NOTIFY_CHAT, "%s demoted %s from %s for %q.", ply:Name(), victim:Name(), team.GetName(tid), reason);
	end
};

-- Save everyone's shizzle
GM:RegisterCommand{
	Command     = "save";
	Access      = "a";
	Help        = "Force an instant save of everyone's profiles.";
	function(ply)
		player.SaveAll(true);
		GM:Log(EVENT_PUBLICEVENT,"%s saved everyone's profiles.", ply:Name())
	end
};

-- A command to privately message a player.
GM:RegisterCommand{
	Command     = "pm";
	Arguments   = "<target> <message>";
	Types       = "Player ...";
	Help        = "Send someone a private OOC message";
	function(ply, victim, words)
		if (victim == ply) then
			return false, "You can't PM yourself.";
		end
		words = string.sub (words, 1, 125)
		words = string.Trim(words);
		if (words == "") then
			return false, "You must specify a message!";
		end
		GM:Log(EVENT_SUPEREVENT, "%s pmed %s: %s",ply:Name(), victim:Name(), words)
		-- Print a message to both players participating in the private message.
		cider.chatBox.add(victim, ply, "pm", words);
		words = "@" ..    victim:Name() .. " " .. words;
		cider.chatBox.add(ply,    ply, "pm", words);
	end
};

GM:RegisterCommand{
	Command     = "givemoney";
	Arguments   = "<amount>";
	Types       = "Number";
	Help        = "Give money to the person in front of you";
	function(ply, amt)
		local tr = ply:GetEyeTrace();
		local victim = tr.Entity;
		if (not (IsValid(victim) and victim:IsPlayer() and tr.StartPos:Distance(tr.HitPos) < 128)) then
			return false, "You must look at a player to give them money!";
		end
		amt = math.floor(amt);
		if (amt < 1) then
			return false, "You must specify a valid amount of money!";
		end
		if (not ply:CanAfford(amt)) then
			return false, "You do not have enough money!";
		end
		ply:GiveMoney(-amt);
		victim:GiveMoney(amt);
		ply:Emote("hands " .. victim:Name() .. " a wad of money.");
		ply:Notify("You gave " .. victim:Name() .. " $" .. amt .. ".", 0);
		victim:Notify(ply:Name() .. " gave you $" .. amt .. ".", 0);
		GM:Log(EVENT_EVENT, "%s gave %s $%i.", ply:Name(), victim:Name(), amt);
	end
};

-- A command to drop money.
GM:RegisterCommand{
	Command     = "dropmoney";
	Arguments   = "<amount>";
	Types       = "Number";
	Help        = "Drop money in front of you";
	function(ply, amt)
		-- Prevent fucktards spamming the dropmoney command.
		ply._NextMoneyDrop = ply._NextMoneyDrop or 0;
		if ((ply._NextMoneyDrop or 0) > CurTime()) then
			return false, "You need to wait another " .. (ply._NextMoneyDrop - CurTime()).. " seconds before dropping more money.";
		end
		local pos = ply:GetEyeTraceNoCursor().HitPos;
		if (ply:GetPos():Distance(pos) > 255) then
			pos = ply:GetShootPos() + ply:GetAimVector() * 255;
		end
		amt = math.floor(amt);
		if (amt < 1) then
			return false, "You must specify a valid amount of money!";
		elseif (amt < 25) then -- Fucking spammers again.
			return false, "You cannot drop less than $25.";
		elseif (not ply:CanAfford(amt)) then
			return false, "You do not have enough money!";
		end
		ply._NextMoneyDrop = CurTime() + 30;
		ply:GiveMoney(-amt);

		local ent = GM.Items["money"]:Make(pos, amt);
		ent:SetPPOwner(ply);
		ent:SetPPSpawner(ply);

		GM:Log(EVENT_EVENT,"%s dropped $%i.", ply:Name(), amt);
	end
};

GM:RegisterCommand{
	Command     = "note";
	Arguments   = "<message>";
	Types       = "...";
	Help        = "Write a note (on melty paper)";
	function(ply, words)
		if (ply:GetCount("notes") == GM.Config["Maximum Notes"]) then
			return false, "You've hit the notes limit!";
		end
		local pos = ply:GetEyeTraceNoCursor().HitPos;
		if (ply:GetPos():Distance(pos) > 255) then
			pos = ply:GetShootPos() + ply:GetAimVector() * 255;
		end
		words = string.sub (words, 1, 125)
		words = string.Trim(words);
		if (words == "") then
			return false, "You must specify a message!";
		end

		-- Create the money entity.
		local entity = ents.Create("cider_note");

		-- Set the amount and position of the money.
		entity:SetText(words);
		entity:SetPos(pos + Vector(0, 0, 5 ) );

		-- Spawn the money entity.
		entity:Spawn();
		entity:SetPPOwner(ply);
		entity:SetPPSpawner(ply);

		ply:AddCount("notes", entity);
		local index = entity:EntIndex()
		-- Add this to our undo table.
		undo.Create("Note");
			undo.SetPlayer(ply);
			undo.AddEntity(entity);
		undo.Finish();
		GM:Log(EVENT_EVENT, "%s wrote a note: %s", ply:Name(), words);
	end
};

-- A command to change your job title
GM:RegisterCommand{
	Command     = "job";
	Arguments   = "[title]";
	Types       = "...";
	Help        = "Change your job title, or reset it to normal";
	function(ply, words)
		words = words or "";
		words = string.sub (words, 1, 50)
		words = string.Trim(words);
		if (words == "") then
			words = team.GetName(ply:Team());
		end
		ply._Job = words;
		ply:SetNWString("Job", ply._Job);
		ply:Notify("You have changed your job title to '" .. words .. "'.");
		GM:Log(EVENT_EVENT, "%s changed " .. ply._GenderWord .. " job text to %q.", ply:Name(), words);
	end
};

-- A command to change your clan.
GM:RegisterCommand{
	Command     = "clan";
	Arguments   = "[name]";
	Types       = "...";
	Help        = "Set the name of the clan you are in, or 'none' to set it to nothing";
	function(ply, words)
		words = words or "";
		words = string.sub (words, 1, 50)
		words = string.Trim(words);
		if (words == "none" or words == "quit") then
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
	end
};

-- A command to change your gender.
GM:RegisterCommand{
	Command     = "gender";
	Arguments   = "<male|female>";
	Types       = "Phrase";
	Help        = "Set your gender";
	function(ply, gender)
		if (string.lower(ply._Gender) == gender) then
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
	end
};

-- A command to yell in character.
GM:RegisterCommand{
	Command     = "y";
	Arguments   = "<words>";
	Types       = "...";
	Help        = "Yell words twice as loud as normal speaking";
	function(ply, words)
		-- Print a message to other players within a radius of the player's position.
		cider.chatBox.addInRadius(ply, "yell", words, ply:GetPos(), GM.Config["Talk Radius"] * 2);
	end
};

-- A command to whisper in character.
GM:RegisterCommand{
	Command     = "w";
	Arguments   = "<words>";
	Types       = "...";
	Help        = "Whisper words half as loud as normal speaking";
	function(ply, words)
		-- Print a message to other players within a radius of the player's position.
		cider.chatBox.addInRadius(ply, "whisper", words, ply:GetPos(), GM.Config["Talk Radius"] / 2);
	end
};

-- A command to do 'me' style text.
GM:RegisterCommand{
	Command     = "me";
	Arguments   = "<words>";
	Types       = "...";
	Help        = "Describe an action in character, such as /me cries a river.";
	function(ply, words)
		ply:Emote(words);
	end
};

-- A command to send an advert to all players.
GM:RegisterCommand{
	Command     = "advert";
	Arguments   = "<words>";
	Types       = "...";
	Help        = "Send an advert to all players. (Costs $"..GM.Config["Advert Cost"]..")";
	function(ply, words)
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
		ply._NextAdvert = CurTime() + GM.Config["Advert Timeout"]
		-- Print a message to all players.
		cider.chatBox.add(nil, ply, "advert", words);
		ply:GiveMoney(-GM.Config["Advert Cost"]);
		GM:Log(EVENT_EVENT, "%s advertised %q",ply:Name(),words)
	end
};

-- A command to change your team.
GM:RegisterCommand{
	Command     = "team";
	Arguments   = "<identifier>";
	Types       = "string";
	Help        = "Change your team";
	function(ply, identifier)
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
	end
};

-- A command to perform inventory action on an item.
GM:RegisterCommand{
	Command     = "inventory";
	Arguments   = "<id> <action> [amount]";
	Types       = "String String Number";
	Hidden      = true;
	function(ply, id, action, amount)
		id = string.lower(id);
		action = string.lower(action);
		local item = GM.Items[id];
		if (not item) then
			return false, "Invalid item specified.";
		end
		local holding = ply.cider._Inventory[id]
		if (not holding or holding < 1) then
			return false, "You do not own any " .. item.Plural .."!";
		end

		if (action == "destroy") then
			item:Destroy(ply);

		-- START CAR ACTIONS (TODO: find some other way of doing this?)
		elseif (action == "pickup") then
			item:Pickup(ply);
		elseif (action == "sell") then
			item:Sell(ply);
		-- END CAR ACTIONS

		elseif (action == "drop") then
			-- Amount wizardry
			if (not amount) then
				amount = 1;
			elseif (amount == 0) then
				amount = holding;
			elseif (amount < 0) then
				return false, "Invalid amount!";
			end
			-- if people want to put '99999' instead of hitting 'all', let them.
			amount = math.min(amount, holding);
			-- Locate positions
			local pos = ply:GetEyeTraceNoCursor().HitPos;
			if (ply:GetPos():Distance(pos) > 255) then
				pos = ply:GetShootPos() + ply:GetAimVector() * 255;
			end
			-- FIRE!
			return item:Drop(ply, pos, amount);
		elseif (action == "use") then
			local time = CurTime();
			-- TODO: When being item limited starts to piss me off (it will!), remove/nerf it.
			-- TODO: Create a ticket about the above todo notice.
			if ((ply._NextUseItem or 0) > time) then
				return false, "You cannot use another item for " .. math.ceil(ply._NextUseItem - time) .. " more seconds!";
			elseif ((ply._NextUse[id] or 0) > time) then
				return false, "You cannot use another " .. item.Name .. " for " .. math.ceil(ply._NextUse[id]) .. " more seconds!";
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
			-- TODO: Make the vehicles plugin use PlayerCalledItemAction!
		elseif (not gamemode.Call("PlayerCalledItemAction", ply, item, action, amount)) then
			return false, "Invalid action specified!"
		end
	end
};

local function containerHandler(ply, item, action, number)
	local container = ply:GetEyeTraceNoCursor().Entity
	if not (IsValid(container) and cider.container.isContainer(container) and ply:GetPos():Distance( ply:GetEyeTraceNoCursor().HitPos ) <= 128) then
		return false,"That is not a valid container!"
	elseif not gamemode.Call("PlayerCanUseContainer",ply,container) then
		return false,"You cannot use that container!"
	end
	item = string.lower(item)
	if (number < 0) then
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
		elseif (number == 0) then
			number = amount;
		elseif (number > amount) then
			number = amount;
		end
	else
		local amount = cInventory[item]
		if (not amount) then
			return false, "There is none of that item in here!";
		elseif (amount < 0) then
			return false, "You cannot take that item out!";
		elseif (number == 0) then
			number = amount;
		elseif (number > amount) then
			number = amount;
		end
	end
	if filter and action == "put" and not filter[item] then
		return false, "You cannot put that item in!"
	end
	do
		local action = action == "put" and CAN_PUT or CAN_TAKE
		if not( bit.band(action, io) == action) then
			return false,"You cannot do that!"
		end
	end
	if number == 0 then return false, "Invalid amount!" end
	if action == "take" then number = -number end
	return cider.container.update(container,item,number,nil,ply)
end

GM:RegisterCommand{
	Command     = "container";
	Arguments   = "<Item> <Put|Take> <amount>";
	Types       = "String Phrase Number";
	Hidden      = true;
	function(ply, ...)
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
	end
};

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
	GM:RegisterCommand{
		Command     = "holster";
		function(ply)
			local weapon = ply:GetActiveWeapon();

			-- Check if they can holster another weapon yet.
			-- TODO: Again I have excersised democracy and will probs want to remove this at some point
			if ( ply._NextHolsterWeapon and ply._NextHolsterWeapon > CurTime() ) then
				return false, "You cannot holster this weapon for "..math.ceil( ply._NextHolsterWeapon - CurTime() ).." second(s)!";
			else
				ply._NextHolsterWeapon = CurTime() + 2;
			end

			-- Check if the weapon is a valid entity.
			if not ( IsValid(weapon) and GM.Items[weapon:GetClass()] ) then
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
		end
	};
end

GM:RegisterCommand{
	Command     = "drop";
	Help        = "Put in for people used to other gamemodes. Don't use it.";
	function()
		return false, "Use /holster";
	end
};

-- A command to perform an action on a door.
GM:RegisterCommand{
	Command     = "entity";
	Arguments   = "<rename|purchase|sell> [name]";
	Types       = "Phrase ...";
	Hidden      = true;
	function(ply, action, name)
		local tr = ply:GetEyeTraceNoCursor();
		local ent = tr.Entity
		-- Let's find out what we're working with
		if (not (IsValid(ent) and ent:IsOwnable() and tr.StartPos:Distance(tr.HitPos) < 128)) then
			return false, "You must be looking at something ownable!";
		end
		-- Deal with the name
		if (name) then
			name = name:sub(1, 24):Trim();
			local lower = name:lower();
			if (lower:find("for sale") or lower:find("f2") or lower == "nobody") then
				name = ply:Name() .. "'s " .. (ent._isDoor and "door" or ent:GetNWString("Name","thingie"));
			end
		else
			name = ply:Name() .. "'s " .. (ent._isDoor and "door" or ent:GetNWString("Name","thingie"));
		end
		-- Start the checks!
		if (ent:IsOwned()) then
			if (action == "purchase") then
				return false, "Someone else already owns this!";
			elseif (ent:GetOwner() ~= ply) then
				return false, "This isn't yours!";
			elseif (action == "rename") then
				-- Make sure they can
				if (not gamemode.Call("PlayerCanSetEntName", ply, ent)) then
					return false, "You cannot set this entity's name";
				end
				-- Grab the old one for loggin
				local oldname = ent:GetDisplayName()
				-- Doo eet
				ent:SetDisplayName(name)
				-- Loggin.
				GM:Log(EVENT_ENTITY, "%s changed " .. ply._GenderWord .. " %s's name from %q to %q.", ply:Name(), ent._isDoor and "door" or ent:GetNWString("Name","entity"), oldname, name);
			elseif (action == "sell") then
				if (ent._Unsellable) then
					return false, "You can't sell this!";
				end
				-- Horray for verbose logging!
				if (ent:IsDoor()) then
					GM:Log(EVENT_ENTITY, "%s sold " .. ply._GenderWord .. " %s %s.", ply:Name(), "door", ent:GetDoorName());
					ply:TakeDoor(ent);
				else
					GM:Log(EVENT_ENTITY, "%s sold " .. ply._GenderWord .. " %s %s.", ply:Name(), ent:GetNWString("Name","entity"), ent:GetDisplayName());
					-- TODO: Maybe this should call some kind of hook so plugins that utilise this can do shizzle?
					ent:TakeAccessFromPlayer(ply);
				end
				return true;
			end
			return false, "Invalid action!";
		elseif (action ~= "purchase") then
			return false, "You can't do that to this!";
		elseif (not ent:IsDoor()) then
			return false, "Shit I aint done this yet sorry!"; -- TODO: Do this yet
		elseif (not (gamemode.Call("PlayerCanOwnDoor", ply, ent) and ply:CheckLimit("doors"))) then
			return false;
		end
		-- Capitalism, Ho!
		local cost = GM.Config["Door Cost"];
		local can, result = ply:CanAfford(cost);
		if (not can) then
			return false,"You need another $" .. result .. " to buy that door!";
		end
		ply:GiveMoney(-cost);
		-- Do the work
		ply:GiveDoor(ent, name);
		ent:SetPPSpawner(NULL);
		GM:Log(EVENT_EVENT, "%s bought a door called %q.", ply:Name(), ent:GetDoorName());
	end
};

local function enthandle(ply, ent, action, kind, id)
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
GM:RegisterCommand{
	Command     = "access";
	Arguments   = "<Give|Take> <kind> <id>";
	Types       = "Phrase String Number";
	Hidden      = true;
	Help        = "oh fuck I'm a badger";
	function(ply, ...)
		local tr = ply:GetEyeTraceNoCursor();
		local ent = tr.Entity
		if (not (IsValid(ent) and ent:IsOwnable() and ply:GetPos():Distance(tr.HitPos) < 128)) then
			return false, "You must be looking at an entity!";
		elseif (ent:GetOwner() ~= ply) then
			return false, "You do not own this!";
		end
		local res, err = enthandle(ply, ent, ...);
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
	end
};

-- A command to manufacture an item.
GM:RegisterCommand{
	Command     = "manufacture";
	Arguments   = "<ItemID>";
	Types       = "String";
	Hidden      = true;
	function(ply, itemid)
		local item = GM:GetItem(itemid);
		if (not item) then
			return false, "No such item '" .. itemid .. "'!";
		elseif (not gamemode.Call("PlayerCanManufactureCategory", ply, item.Category)) then
			return false, ply:GetTeam().Name .. "s cannot manufacture "..GM:GetCategory(item.Category).Name.."!";
		elseif (not gamemode.Call("PlayerCanManufactureItem", ply, item)) then
			return false;
		elseif (not ply:IsAdmin() and (ply.NextManufactureItem or 0) > CurTime()) then
			return false, "You cannot manufacture another item for "..math.ceil( ply.NextManufactureItem - CurTime() ).." second(s)!";
		elseif (item.canManufacture and not item:canManufacture(ply)) then
			return false;
		end
		local amt = item.Batch;
		local price = item.Cost * amt;
		local can, req = ply:CanAfford(price);
		if (not can) then
			return false, "You need another $" .. req .. " to afford that!";
		end
		ply:GiveMoney(-price);
		ply.NextManufactureItem = CurTime() + 5;

		local tr = ply:GetEyeTraceNoCursor();
		local ent = item:Make(tr.HitPos + Vector(0,0,16), amt);
		if (item.onManufacture) then
			item:onManufacture(ply, ent, amt);
		end
		ent:SetPPOwner(NULL);
		local words = "";
		if (amt > 1) then
			words = amt .. " " .. item.Plural;
		else
			words = "a " .. item.Name;
		end
		ply:Notify("You manufactured " .. words .. ".");
		GM:Log(EVENT_EVENT, "%s manufactured %s.", ply:Name(), words);
	end
};

-- A command to warrant a player.
GM:RegisterCommand{
	Command     = "warrant";
	Arguments   = "<Target> <Arrest|Search>";
	Types       = "Player Phrase";
	Help        = "Give someone a warrant";
	function(ply, target, class)
		if (not target:Alive()) then
			return false, target:Name() .. " is dead!";
		elseif (target._CannotBeWarranted > CurTime()) then
			return false, target:Name() .. " can't be warranted right now!";
		elseif (target:Arrested()) then
			return false, target:Name() .. " is currently arrested!";
		elseif (target._Warranted == class) then
			return false, target:Name() .. " already has a" .. (class == "arrest" and "n " or " ") .. class .. " warrant!";
		elseif (class == "search" and target._Warranted == "arrest") then
			return false, target:Name() .. " already has an arrest warrant!";
		elseif (not gamemode.Call("PlayerCanWarrant", ply, target, class)) then
			return false;
		end
		gamemode.Call("PlayerWarrant", ply, target, class);
		target:Warrant(class);
	end
};

-- A command to unwarrant a player.
GM:RegisterCommand{
	Command     = "unwarrant";
	Arguments   = "<Target>";
	Types       = "Player";
	Help        = "Revoke someone's warrant.";
	function(ply, target)
		if (not target._Warranted) then
			return false, target:Name() .. " isn't warranted!";
		elseif (not gamemode.Call("PlayerCanUnwarrant", ply, target)) then
			return false;
		end
		gamemode.Call("PlayerUnwarrant", ply, target);
		target:UnWarrant();
	end
};

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
	GM:RegisterCommand{
		Command     = "sleep";
		Help        = "Go to sleep or wake up while asleep.";
		function(ply)
			if (ply._Sleeping and ply:KnockedOut()) then
				return ply:WakeUp();
			end
			ply:SetCSVar(CLASS_LONG, "_GoToSleepTime", CurTime() + GM.Config["Sleep Waiting Time"]);
			timer.Conditional(ply:UniqueID().." sleeping timer", GM.Config["Sleep Waiting Time"], conditional, success, failure, ply, ply:GetPos());
		end
	};
end

-- A command to send a message to all players on the same team.
GM:RegisterCommand{
	Command     = "radio";
	Arguments   = "<Text>";
	Types       = "...";
	Help        = "Send a radio message to all players on your team";
	function(ply, text)
		ply:SayRadio(text);
	end
};

-- TODO: Merge /trip and /fallover?
GM:RegisterCommand{
	Command     = "trip";
	Help        = "Fall over while walking. (bind key \"say /trip\")";
	function(ply)
		if ply:GetVelocity() == Vector(0,0,0) then
			return false,"You must be moving to trip!"
		elseif ply:InVehicle() then
			return false,"There is nothing to trip on in here!";
		end
		ply:KnockOut(5)
		ply._Tripped = true
		--cider.chatBox.addInRadius(ply, "me", "trips and falls heavily to the ground.", ply:GetPos(), GM.Config["Talk Radius"]);
		ply:Emote("trips and falls heavily to the ground.");
		GM:Log(EVENT_EVENT,"%s fell over.",ply:GetName())
	end
};

GM:RegisterCommand{
	Command     = "fallover";
	Help        = "Fall over while not walking. (bind key \"say /fallover\")";
	function(ply)
		if not (ply:KnockedOut() or ply:InVehicle()) then
			ply:KnockOut(5)
			ply._Tripped = true
			cider.chatBox.addInRadius(ply, "me", "slumps to the ground.", ply:GetPos(), GM.Config["Talk Radius"]);
			GM:Log(EVENT_EVENT,"%s fell over.",ply:GetName())
		end
	end
};


local function canmutiny(ply, victim)
	local pt, vt = ply:GetTeam(), victim:GetTeam();
	return pt.Group == vt.Group
	and    pt.Gang  == pt.Gang and pt.Gang
	and    vt.GroupLevel == GROUP_GANGBOSS;
end
GM:RegisterCommand{
	Command     = "mutiny";
	Arguments   = "<Target>"; -- TODO: Why doesn't mutiny know who you're rebelling against?
	Types       = "Player";
	Help        = "Attempt to overthrow your leader";
	function(ply, victim)
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
	end
};

-- A command to give Donator status to a player.
--[[
cider.com mand.add("donator", "s", 1, function(ply, arguments)
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
--]]
-- A command to change your details
GM:RegisterCommand{
	Command     = "details";
	Arguments   = "<text|none>";
	Types       = "...";
	Help        = "Set your visible details. Use the word none to blank them out.";
	function(ply, text)
		text = text:sub(1,64):Trim()
		if (string.lower(text) == "none") then
			ply._Details = "";
			ply:Notify("You have removed your details.");
			GM:Log(EVENT_EVENT, "%s changed "..ply._GenderWord.." details to %q.", ply:Name(), "nothing")
		else
			ply._Details = text;
			ply:Notify("You have changed your details to '" .. text .. "'.");
			GM:Log(EVENT_EVENT, "%s changed "..ply._GenderWord.." details to %q.", ply:Name(), text)
		end
		ply:SetNWString("Details", ply._Details);
	end
};

GM:RegisterCommand{
	Command     = "action";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Emit a localised environmental emote";
	function(ply, text)
		cider.chatBox.addInRadius(ply, "action", text, ply:GetPos(), GM.Config["Talk Radius"]);
	end
};

GM:RegisterCommand{
	Command     = "globalaction";
	Access      = "m";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Emit a global environmental emote";
	function(ply, text)
		cider.chatBox.add(nil,ply, "action", text);
	end
};
GM:RegisterCommand{
	Command     = "globalaction";
	Access      = "m";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Emit a global environmental emote";
	function(ply, text)
		cider.chatBox.add(nil,ply, "action", text);
	end
};

GM:RegisterCommand{
	Command     = "ooc";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Say something out of character to everyone on the server. Shortcut: //<text>";
	function(ply, text)
		if (not gamemode.Call("PlayerCanSayOOC", ply, text)) then
			return false;
		end
		cider.chatBox.add(nil, ply, "ooc", text);
		--GM:Log(EVENT_TALKING,"(OOC) %s: %s",player:Name(),text)
	end
};

GM:RegisterCommand{
	Command     = "looc";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Say something out of character to the people around you. Shortcut: .//<text>";
	function(ply, text)
		if (not gamemode.Call("PlayerCanSayLOOC", ply, text)) then
			return false;
		end
		cider.chatBox.addInRadius(ply, "looc", text, ply:GetPos(), GM.Config["Talk Radius"]);
		--GM:Log(EVENT_TALKING,"(Local OOC) %s: %s",player:Name(),text)
	end
};

-- Set an ent's master
GM:RegisterCommand{
	Command     = "setmaster";
	Access      = "s";
	Arguments   = "<EntityID|0>";
	Types       = "number";
	Help        = "Set/Unset the ownership 'master' of an entity.";
	function(ply, masterID)
		local entity = ply:GetEyeTraceNoCursor().Entity
		local master = Entity(masterID)
		if not (IsValid(entity) and entity:IsOwnable()) then
			return false,"That is not a valid entity!"
		elseif not ((IsValid(master) and master:IsOwnable()) or masterID == 0) then
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
	end
};

-- Seal a door
GM:RegisterCommand{
	Command     = "seal";
	Access      = "s";
	Arguments   = "[Unseal]";
	Types       = "bool";
	Help        = "Seal or unseal a door.";
	function(ply, unseal)
		local entity = ply:GetEyeTraceNoCursor().Entity
		if not (IsValid(entity) and entity:IsOwnable()) then
			return false,"That is not a valid entity!"
		end
		if unseal then
			entity:UnSeal();
			hook.Call("EntitySealed",GAMEMODE,entity,true)
			GM:Log(EVENT_ENTITY, "%s unsealed a %s,",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
		else
			entity:Seal();
			hook.Call("EntitySealed",GAMEMODE,entity)
			GM:Log(EVENT_ENTITY, "%s sealed a %s,",ply:Name(),entity._isDoor and "door" or entity:GetNWString("Name","entity"))
		end
	end
};

GM:RegisterCommand{
	Command     = "setname";
	Access      = "s";
	Arguments   = "<Name|'Clear'>";
	Types       = "...";
	Help        = "Set the displayed name for a door. 'Clear' with 's to set it to nothing.";
	function(ply, words)
		local entity = ply:GetEyeTraceNoCursor().Entity
		if not (IsValid(entity) and entity:IsOwnable() and entity._isDoor) then
			return false,"That is not a valid door!"
		end
		if (string.lower(words) == "'clear'") then
			words = "";
		end
		entity:SetNWString("Name",words)
		GM:Log(EVENT_ENTITY, "%s changed a door's name to %q.",ply:Name(),words)
		hook.Call("EntityNameSet",GAMEMODE,entity,words)
	end
};

GM:RegisterCommand{
	Command     = "clearowner";
	Access      = "s";
	Help        = "Remove the owner of an entity.";
	function(ply)
		local ent = ply:GetEyeTraceNoCursor().Entity
		if (not (IsValid(ent) and ent:IsOwnable())) then
			return false, "You cannot set the owner of this!";
		end
		-- Slavery
		ent = ent:GetMaster() or ent;
		ent:ClearOwnershipData();
		GM:Log(EVENT_ENTITY, "%s wiped the ownership data on %s",
			ply:Name(), ent:GetNWString("Name", "an entity"));
		gamemode.Call("EntityOwnerSet", ent, nil)
	end
};


GM:RegisterCommand{
	Command     = "setowner";
	Access      = "s";
	Arguments   = "<player|team|group|gang> <identifier>";
	Types       = "Phrase String";
	Help        = "Set the owner of an entity.";
	function(ply, kind, id)
		local ent = ply:GetEyeTraceNoCursor().Entity
		if (not (IsValid(ent) and ent:IsOwnable())) then
			return false, "You cannot set the owner of this!";
		end
		-- Slavery
		ent = ent:GetMaster() or ent;
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
	end
};

GM:RegisterCommand{
	Command     = "a";
	Access      = "a";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Say send a message to all the other admins on the server";
	function(ply, text)
		local rp = RecipientFilter()
		for _,ply in pairs(player.GetAll()) do
			if (ply:IsAdmin()) then
				rp:AddPlayer(ply)
			end
		end
		cider.chatBox.add(rp, ply, "achat", text);
	end
};

GM:RegisterCommand{
	Command     = "m";
	Access      = "m";
	Arguments   = "<Message>";
	Types       = "...";
	Help        = "Say send a message to all the other staff on the server";
	function(ply, text)
		local rp = RecipientFilter()
		for _,ply in pairs(player.GetAll()) do
			if (ply:IsModerator()) then
				rp:AddPlayer(ply)
			end
		end
		cider.chatBox.add(rp, ply, "mchat", text);
	end
};
