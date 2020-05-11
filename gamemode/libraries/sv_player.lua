--
-- ~ Serversie Player Library ~
-- ~ Applejack ~
--
local player, umsg, pairs, ipairs, string, timer, IsValid, table = player, umsg,
                                                                   pairs,
                                                                   ipairs,
                                                                   string,
                                                                   timer,
                                                                   IsValid,
                                                                   table

---
-- Allows plugins to add their own flags and functions to HasAccess without resorting to dirty hacks.
-- @usage GM.FlagFunctions[flag] = function(ply) return true end;
GM.FlagFunctions = {
	s = function(ply)
		return ply:IsSuperAdmin()
	end,
	a = function(ply)
		return ply:IsAdmin()
	end,
	m = function(ply)
		return ply:IsModerator()
	end,
}

---
-- Provides a quick uid->player lookup.
player.UniqueIDs = {}

---
-- Gets a player by a part of their name, or their steamID, or their UniqueID, or their UserID.
-- Will provide the player with the shortest name that matches the key. That way a search for 'lex' will return '||VM|| Lexi' even if 'LeXiCaL1ty{GT}' is available.
-- @param id An ID to search for the player by.
-- @return A player if one is found, nil otherwise.
function player.Get(id)
	local res, len, name, num, pname, lon;
	name = string.lower(id);
	id = string.upper(id);
	num = tonumber(id);
	res = player.UniqueIDs[num];
	if (res) then
		return res;
	end
	for _, ply in pairs(player.GetAll()) do
		pname = ply:Name():lower();
		if ((num and ply:UserID() == num) or ply:SteamID() == id) then
			return ply;
		elseif (pname:find(name)) then
			lon = pname:len();
			if (res) then
				if (lon < len) then
					res = ply;
					len = lon;
				end
			else
				res = ply;
				len = lon;
			end
		end
	end
	return res;
end
-- Compat
function GM:GetPlayer(id)
	return player.Get(id);
end

---
-- Notifies every player on the server that has the specified access.
-- @param access The access string to search for
-- @param message The message to display
-- @param level The notification level. Nil or unspecified = chat message. 0 = Water drip. 1 = Failure buzzer. 2 = 'Bip' Notification. 3 = 'Tic' Notification. (Used by the cleanup)
function player.NotifyByAccess(access, message, class)
	for _, ply in pairs(player.GetAll()) do
		if (ply:HasAccess(access)) then
			ply:Notify(message, class);
		end
	end
end

---
-- Notifies every player on the server and logs a public event
-- @see MS:Log
-- @param message The message to display. (Use same form as MS:Log)
-- @param level The notification level. Nil or unspecified = chat message. 0 = Water drip. 1 = Failure buzzer. 2 = 'Bip' Notification. 3 = 'Tic' Notification. (Used by the cleanup)
-- @param ... A series of strings to be applied to the message string via string.format().
function player.NotifyAll(level, message, ...)
	-- Insurance.
	-- FIXME: Remove this before going into production.
	if (level and type(level) ~= "number") then
		error("Invalid level specified for NotifyAll!", 2);
	end
	local msg = message:format(...);
	for _, ply in pairs(player.GetAll()) do
		ply:Notify(msg, level);
	end
	MS:Log(EVENT_PUBLICEVENT, message, ...);
end

--
-- Functions for the timer from now on only
--
local autosendvars = {};
---
-- Adds a CS var that should be updated every second.
-- @param type What TYPE_ enum the variable is
-- @param name The name of the variable (Value sent will be ply[name])
function player.AddAutoCSVar(type, name)
	autosendvars[name] = type;
end

hook.Add(
	"PlayerSecond", "CSVar Sync", function(ply)
		for k, v in pairs(autosendvars) do
			ply:SetCSVar(v, k, ply[k]);
		end
		-- And the one CSVar that needs manual doin
		ply:SetCSVar(CLASS_LONG, "_Money", ply.cider._Money);

	end
)

hook.Add(
	"LibrariesLoaded", "Player Library's LibrariesLoaded", function()
		player.AddAutoCSVar(CLASS_STRING, "_NextSpawnGender");
		player.AddAutoCSVar(CLASS_STRING, "_Gender");
		player.AddAutoCSVar(CLASS_FLOAT, "_ScaleDamage");
		player.AddAutoCSVar(CLASS_BOOL, "_HideHealthEffects");
		player.AddAutoCSVar(CLASS_BOOL, "_Sleeping");
		player.AddAutoCSVar(CLASS_BOOL, "_GPS");
		player.AddAutoCSVar(CLASS_BOOL, "_Stunned");
		player.AddAutoCSVar(CLASS_BOOL, "_StuckInWorld");
		player.AddAutoCSVar(CLASS_LONG, "_JobTimeLimit");
		player.AddAutoCSVar(CLASS_LONG, "_JobTimeExpire");
		player.AddAutoCSVar(CLASS_LONG, "_Salary");
	end
);
