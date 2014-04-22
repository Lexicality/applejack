--[[
	~ Plugin Library ~
	~ Applejack ~
--]]

local stored = {};
GM.Plugins = stored;

--[[
	Makes any hook call act like cider.plugin.call acted.
	(This has the added bonus of making plugin hooks immortal like gamemode ones.)
--]]
if (not hook.oCall) then
	hook.oCall = hook.Call;
end
function hook.Call(name,gm,...)
	local success, a, b, c, d, e, f, g, h;
	for _,plugin in pairs(stored) do
		if (type(plugin[name]) == "function") then
			success, a, b, c, e, f, g, h = pcall(plugin[name],plugin,...);
			if (not success) then
				ErrorNoHalt("["..os.date().."] Applejack "..plugin.Name.." Plugin: Hook "..name.." failed: "..a.."\n");
			elseif (a ~= nil) then
				return a,b,c,d,e,f,g,h;
			end
		end
	end
	return hook.oCall(name,gm,...);
end
--]]
---
-- Loads all the plugins
function GM:LoadPlugins()
	local count = 0;
	MsgN("Applejack: Loading Plugins:");
	local path = self.LuaFolder.."/gamemode/plugins/";
	local cpath;
	local files, folders = file.Find(path.."*", "LUA");
	for _,id in pairs(folders) do
		if (not id:find(".",1,true)) then
			cpath = path..id;
			PLUGIN = {};
			PLUGIN.Folder = id;
			PLUGIN.FullPath = cpath;
			if (file.Exists(cpath.."/sh_init.lua", "LUA")) then
				includecs(cpath.."/sh_init.lua");
			end
			if (SERVER) then
				if (file.Exists(cpath.."/sv_init.lua", "LUA")) then
					include(cpath.."/sv_init.lua");
				end if (file.Exists(cpath.."/cl_init.lua", "LUA")) then
					AddCSLuaFile(cpath.."/cl_init.lua");
				end
			elseif (file.Exists(cpath.."/cl_init.lua", "LUA")) then
				include(cpath.."/cl_init.lua");
			end
			if (file.FolderExistsInLua(cpath.."/items")) then
				PLUGIN._HasItems = true;
			end
			if (file.FolderExistsInLua(cpath.."/teams")) then
				PLUGIN._HasTeams = true;
			end
			if (PLUGIN.Name) then
				MsgN(" Loaded plugin '"..PLUGIN.Name.."'")
				stored[id] = PLUGIN;
				count = count + 1;
			end
		end
	end
	PLUGIN = nil;
	if (self.Inited) then
		hook.Call("LoadData",self);
	end
	MsgN("Applejack: Loaded ",count," plugins.\n");
end

-- Concommand for debug
if SERVER then
	concommand.Add("cider_reload_plugins",function(ply)
		if (IsValid(ply) and not ply:IsSuperAdmin()) then return end
		GM:LoadPlugins();
	end)
elseif GetConVarNumber("developer") > 0 then -- Don't want the peons to get this command.
	concommand.Add("cider_reload_plugins_cl",function()
		GM:LoadPlugins();
	end)
end

---
-- Returns a plugin based on it's ID or name
-- @param id What to look for
-- @return The plugin you wanted or nil
function GM:GetPlugin(id)
	-- If we're passed a valid plugin ID, then return the plugin
	id = string.lower(id);
	if (stored[id]) then
		return stored[id];
	end
	local res, len;
	-- Otherwise, we're looking for part of a name.
	for _,data in pairs(stored) do
		if (data.Name:lower():find(id)) then
			local lon = data.Name:len();
			if (res) then
				if (lon < len) then
					res = data;
					len = lon;
				end
			else
				res = data;
				len = lon;
			end
		end
	end
	return res
end
