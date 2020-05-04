-- A command to warrant a player.
GM:RegisterCommand{
	Command = "warrant",
	Arguments = "<Target> <Arrest|Search>",
	Types = "Player Phrase",
	Help = "Give someone a warrant",
	function(ply, target, class)
		if (not target:Alive()) then
			return false, target:Name() .. " is dead!";
		elseif (target._CannotBeWarranted > CurTime()) then
			return false, target:Name() .. " can't be warranted right now!";
		elseif (target:Arrested()) then
			return false, target:Name() .. " is currently arrested!";
		elseif (target._Warranted == class) then
			return false,
       			target:Name() .. " already has a" ..
       				(class == "arrest" and "n " or " ") .. class .. " warrant!";
		elseif (class == "search" and target._Warranted == "arrest") then
			return false, target:Name() .. " already has an arrest warrant!";
		elseif (not gamemode.Call("PlayerCanWarrant", ply, target, class)) then
			return false;
		end
		gamemode.Call("PlayerWarrant", ply, target, class);
		target:Warrant(class);
	end,
};

-- A command to unwarrant a player.
GM:RegisterCommand{
	Command = "unwarrant",
	Arguments = "<Target>",
	Types = "Player",
	Help = "Revoke someone's warrant.",
	function(ply, target)
		if (not target._Warranted) then
			return false, target:Name() .. " isn't warranted!";
		elseif (not gamemode.Call("PlayerCanUnwarrant", ply, target)) then
			return false;
		end
		gamemode.Call("PlayerUnwarrant", ply, target);
		target:UnWarrant();
	end,
};

-- Arrest a player with optional arrest time
GM:RegisterCommand{
	Command = "arrest",
	Access = "s",
	Arguments = "<victim> [time]",
	Types = "Player Number",
	Category = "Superadmin Abuse Commands",
	Help = "Arrest someone. Optionally define how long they're arrested for.",
	function(ply, victim, time)
		victim:Arrest(time);
		GM:Log(EVENT_EVENT, "%s arrested %s", ply:Name(), victim:Name());
	end,
};

-- Unarrest a player
GM:RegisterCommand{
	Command = "unarrest",
	Access = "s",
	Arguments = "<victim>",
	Types = "Player",
	Category = "Superadmin Abuse Commands",
	Help = "Unarrest someone.",
	function(ply, victim)
		victim:UnArrest();
		GM:Log(EVENT_EVENT, "%s unarrested %s", ply:Name(), victim:Name());
	end,
};

-- Give a player an instant warrant with optional length
GM:RegisterCommand{
	Command = "awarrant",
	Access = "s",
	Arguments = "<victim> <arrest|search> [time]",
	Types = "Player Phrase Number",
	Category = "Superadmin Abuse Commands",
	Help = "Instantly give a player a warrant, ignoring game mechanics. Optionally give it a length.",
	function(ply, victim, kind, time)
		GM:Log(
			EVENT_EVENT, "%s gave %s a %s warrant for %s seconds", ply:Name(),
			victim:Name(), kind, time or "default"
		);
		victim:Warrant(kind, time);
	end,
};
