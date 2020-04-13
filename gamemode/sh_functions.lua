--
-- ~ Custom Functions ~
-- ~ Moonshine ~
--
-- Prereq
AddCSLuaFile("sh_functions.lua");

--
-- Globals
--

---
-- Makes sure that files aren't linux/OSX metadata files
-- @param filename The file to check
-- @return True if it is a valid file or false if it's a stray.
function validfile(filename) -- A curse brought on by editing things in mac/linux - Unwanted files!
	return filename:sub(1, 1) ~= "." and not filename:find "~";
end

---
-- Checks if an entity is both valid and a player
-- @param object The object in question
-- @return True if it's valid+player, false otherwise.
function IsPlayer(object)
	return IsValid(object) and object:IsPlayer();
end

--
-- Extensions
--

---
-- Rounds a number to a given number of places
-- @param num The number to round
-- @param places The number of places to round to
-- @return The number, freshly rounded.
function math.DecimalPlaces(num, places)
	return math.Round(num * 10 ^ places) / 10 ^ places
end

---
-- Extends the gamemode.Call function so that it always does the call,
--  even if the gamemode doesn't have the correct function.
-- @param name The hook name to call
-- @param ... The hook arguments
-- @return Whatever hook.Call returns
function gamemode.Call(name, ...)
	local gm = gmod.GetGamemode() or GM or GAMEMODE or {};
	if (not gm[name]) then
		ErrorNoHalt(
			"Hook called '", name, "' called that does not have a GM: function!\n"
		);
		debug.Trace();
	end
	return hook.Call(name, gm, ...);
end

---
-- Checks to see if a vector is within a box of vectors
-- @param topleft The top left vector of the box
-- @param bottomright The bottom right vector of the box
-- @param pos The vector to check
-- @return True if it is completely within the box, false otherwise.
function util.IsWithinBox(topleft, bottomright, pos)
	return pos:WithinAABox(topleft, bottomright);
end

---
-- Works around file.Exists(x, "LUA") returning false on the client for folders
-- @param folder The path to the folder, sans final /
-- @return bool
function file.FolderExistsInLua(folder)
	if (file.Exists(folder, "LUA")) then
		return true;
	end
	local files, folders = file.Find(folder .. "/*", "LUA");
	return #files > 0 or #folders > 0;
end

---
-- Replaces the existing Error function which has stopped working properly
-- @param ... The messsage to be error'd
function Error(...)
	local err = "";
	for _, s in ipairs {...} do
		err = err .. tostring(s);
	end
	error(err, 2);
end
