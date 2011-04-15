--[[
Name: "sh_init.lua".
	~ Applejack ~
--]]
--[[
	Custom ENUM highlights (paste into style configurator)
	TEAM GROUP GANG EVENT_SUPEREVENT EVENT_ADMINEVENT EVENT_EVENT EVENT_POLICEEVENT EVENT_PUBLICEVENT EVENT_DEBUG EVENT_SQLDEBUG EVENT_DEBUGERROR EVENT_ERROR EVENT_ALL EVENT_TALKING EVENT_BUILD EVENT_PICKUP EVENT_COMMAND EVENT_ITEM EVENT_PLAYERDAMAGE EVENT_DAMAGE EVENT_DEATH EVENT_ENTITY EVENT_TEAM CLASS_STRING CLASS_LONG CLASS_SHORT CLASS_BOOL CLASS_VECTOR CLASS_ENTITY CLASS_ANGLE CLASS_CHAR CLASS_FLOAT  TYPE_SMALL TYPE_LARGE CAN_TAKE CAN_PUT  OBJ_OWNABLE OBJ_LOCKED OBJ_SEALED  OBJ_PADLOCKED  OBJ_CONTAINER OBJ_INUSE 
--]]
function includecs(file)
--[[
	if (string.find(file, "shared.lua")) then
		ErrorNoHalt("includecs(\""..file.."\"): "..debug.getinfo(2,"S").source.."\n");
	end
--]]
	include(file);
	AddCSLuaFile(file);
end

GM.Name = "Applejack - Cider Core";
GM.Email = "mwaness@gmail.com";
GM.Author = "Lexi, original gamemode by kuromeku";
GM.Website = "http://www.ventmob.com";
GM.LuaFolder = string.sub(GM.Folder,11,-1)
includecs("timer.lua");
-- Derive the gamemode from sandbox.
DeriveGamemode("Sandbox");
require("datastream")
function math.DecimalPlaces(numb,places)
	return math.Round(numb*10^places)/10^places
end
function validfile(filename) -- A curse brought on by editing things in mac/linux - Unwanted files!
	return filename:sub(1,1) ~= "." and not filename:find"~";
end
-- This makes more sense tbh
function gamemode.Call(name, ...)
	local gm = gmod.GetGamemode() or GM or GAMEMODE or {};
	if (not gm[name]) then
		ErrorNoHalt("Hook called '",name,"' called that does not have a GM: function!\n");
	end
	return hook.Call(name, gm, ...);
end

-- "I do this because I use some of these variable names a lot by habbit." - kuro
-- Left in because shit still uses this that I haven't rewritten yet. - Lexi
for k, v in pairs(_G) do
	if (!tonumber(k) and type(v) == "table") then
		if (!string.find(k, "%u") and string.sub(k, 1, 1) ~= "_") then
			_G[ "g_"..string.upper( string.sub(k, 1, 1) )..string.sub(k, 2) ] = v;
		end
	end
end
--Because some people are numpties and call ValidEntity on non entity objects, so I need to modify what Garry did
--[[---------------------------------------------------------
    Returns true if object is valid (is not nil and IsValid)
---------------------------------------------------------]]--
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
--[[---------------------------------------------------------
    Returns true if entity is valid
---------------------------------------------------------]]--
ValidEntity = IsValid

-- Create the Cider table and the configuration table.
cider = {};

-- Include the configuration and enumeration files.
includecs("sh_enumerations.lua");
includecs("sh_config.lua");

-- Check if we're running on the server.
if (SERVER) then include("sv_config.lua"); end

-- This needs to be here
function GM:LibrariesLoaded()
end

--[[ Loop through the libraries and include them.
local subd
for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/libraries/*.lua") ) do
	if (validfile(v)) then
		subd = string.sub(v, 1, 3);
		if (SERVER) then
			if (subd == "sv_") then
				include("libraries/"..v);
			elseif (subd == "sh_") then
				includecs("libraries/"..v);
			else
				AddCSLuaFile("libraries/"..v);
			end
		else
			if (subd == "cl_" or subd == "sh_") then
				include("libraries/"..v);
			end
		end
	end
end
--]]

-- Moonshine style loading function to generically load the libraries, metatables and anything else you want that uses that sorta ting.
local function doload(path, name, plural) -- path must be the relative path from the Applejack/gamemode/ folder
	if (path:sub(-1) ~= "/") then
		path = path.."/";
	end
	MsgN("Applejack: Loading "..name.."s");
	local count = 0;
	local subd, fname;
	for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/"..path.."*.lua") ) do
		if (validfile(v)) then
			subd = v:sub(1, 3);
			fname = v:sub(4,-5);
			if (subd == "sh_") then
				includecs(path..v);
				MsgN(" Loaded the shared "..fname.." "..name..".");
				count = count + 1;
			elseif (SERVER) then
				if (subd == "sv_") then
					include(path..v);
					MsgN(" Loaded the serverside "..fname.." "..name..".");
					count = count + 1;
				elseif (subd == "cl_") then
					AddCSLuaFile(path..v);
				end
			elseif (subd == "cl_") then
				include(path..v);
				count = count + 1;
				MsgN(" Loaded the clientsideside "..fname.." "..name..".");
			end
		end
	end
	MsgN("Applejack: Loaded "..count.." "..name.."s.\n")
end
doload("libraries/",     "Library",   "Libraries");
doload("metatables/",  "Metatable",  "Metatables");
doload("hooks/", "Hook Library", "Hook Libraries");
gamemode.Call("LibrariesLoaded");

-- Check if we're running on the server.
if (SERVER) then
	include("sv_commands.lua")
	include("sv_umsgs.lua")
	AddCSLuaFile("cl_content.lua")
else
	include("cl_content.lua")
end

-- Whoot for Mewnshien libraries
GM:LoadPlugins()
GM:LoadItems();

--This stuff needs to be after plugins but before everything else
includecs("sh_events.lua")
GM:LoadTeams();


-- Loop through derma panels and include them.
for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/derma/*.lua") ) do
	if (validfile(v)) then
		if (CLIENT) then
			include("derma/"..v);
		else
			AddCSLuaFile("derma/"..v);
		end
	end
end

--A few things need to be shared
function util.IsWithinBox(topleft,bottomright,pos)
	if not (pos.z < math.min(topleft.z, bottomright.z) or pos.z > math.max(topleft.z, bottomright.z) or
			pos.x < math.min(topleft.x, bottomright.x) or pos.x > math.max(topleft.x, bottomright.x) or
			pos.y < math.min(topleft.y, bottomright.y) or pos.y > math.max(topleft.y, bottomright.y)) then
		return true
	end
end

-- Called when a bullet tries to ricochet
function GM:CanRicochet(trace,force,swep)
	return force > 5
end
-- Called when a bullet tries to penetrate
function GM:CanPenetrate(trace,force,swep)
	return force > 7.5
end

function GM:ShouldCollide(one,two)
	return not (IsValid(one) and IsValid(two) and one:GetClass() == "cider_item" and two:GetClass() == "cider_item");
end