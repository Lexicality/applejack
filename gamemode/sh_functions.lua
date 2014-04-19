--[[
	~ Custom Functions ~
	~ Moonshine ~
--]]
-- Prereq
AddCSLuaFile("sh_functions.lua");

--
-- Globals
--

---
-- Include a file and add it to the CSLua Cache
-- @param file The file to add
function includecs(file)
	include(file);
	AddCSLuaFile(file);
end

---
-- Makes sure that files aren't linux/OSX metadata files
-- @param filename The file to check
-- @return True if it is a valid file or false if it's a stray.
function validfile(filename) -- A curse brought on by editing things in mac/linux - Unwanted files!
	return filename:sub(1,1) ~= "." and not filename:find"~";
end

---
-- Because sometimes things go wrong and I need to debug IsValid. (Doesn't happen much anymore tbh)
-- @param object The object to check
-- @return If the object is valid.
function IsValid( object )
	--[[
	local object = object or nil
	local etype = type(object);
	if etype == "number" or etype == "function" or etype == "string" or etype == "boolean" or etype == "thread" then
		error("What the fuck just passed me a non-ent? "..etype,2)
	end
	if (not (object and object.IsValid)) then return false end
	return object:IsValid()
	--]]
	return object and object.IsValid and object:IsValid();
end
IsValid = IsValid

---
-- Checks if an entity is both valid and a player
-- @param object The object in question
-- @return True if it's valid+player, false otherwise.
function IsPlayer( object )
	return IsValid( object ) and object:IsPlayer();
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
	return math.Round(num * 10^places) / 10^places
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
		ErrorNoHalt("Hook called '",name,"' called that does not have a GM: function!\n");
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
	if not (pos.z < math.min(topleft.z, bottomright.z) or pos.z > math.max(topleft.z, bottomright.z) or
			pos.x < math.min(topleft.x, bottomright.x) or pos.x > math.max(topleft.x, bottomright.x) or
			pos.y < math.min(topleft.y, bottomright.y) or pos.y > math.max(topleft.y, bottomright.y)) then
		return true
	end
end

---
-- Checks to see if a filename is able to be include()'d
-- Takes into account the fact that the gamemode folders are in the root of the lua vfs,
-- and the lua_temp folder.
-- @param filename The file to check
-- @return True if the file exists, false otherwise
function file.ExistsInLua(filename)
	-- TODO: Does "LUA" let you do this more easily?
	return  file.Exists("lua/"       .. filename, "MOD") or
			file.Exists("gamemodes/" .. filename, "MOD") or
			file.Exists("lua_temp/"  .. filename, "MOD");
end

