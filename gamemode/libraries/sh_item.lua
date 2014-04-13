--[[
    ~ Shared Item Library ~
    ~ Applejack ~
--]]

local GM    = GM or GAMEMODE;
GM.Items    = {};
local meta    = {};
local cats    = {}; -- meow
local index    = 1;
-- Set the metatable up
meta.__index = meta;
setmetatable(meta,{__call = function(self, tab)
    return setmetatable(tab or {},self);
end})
_R.Item = meta;
local registerCategory;
local newcat,str,count,path,total;
---
-- Loads all the items and categories into GM.Items
function GM:LoadItems()
    path = self.LuaFolder.."/gamemode/items/";
    MsgN("Applejack: Loading Item Bases:")
    for _, filename in pairs(file.Find(path.."base/*.lua", "LUA")) do
        if (validfile(filename)) then
            ITEM = meta();
            ITEM.Name = "NULL"; -- For the search
            includecs(path.."base/"..filename);
            ITEM.UniqueID = filename:sub(1,-5):lower();
            ITEM:Register();
            MsgN(" Loaded item base '"..ITEM.UniqueID.."'");
        end
    end
    total = 0;
    MsgN("Applejack: Loading Categories:");
    local files, folders = file.Find(path.."*", "LUA");
    for _, filename in pairs(folders) do
        if (validfile(filename) and not filename:find('.',1,true) and
                 file.ExistsInLua(path..filename.."/init.lua")) then
            str,count = "",0;
            CAT = {};
            CAT.UniqueID = filename:lower();
            includecs(path..filename.."/init.lua");
            newcat = registerCategory(CAT);
            _E['CATEGORY_'..string.upper(filename)] = newcat;
            for _, item in pairs(file.Find(path..filename.."/*.lua", "LUA")) do
                if (validfile(item) and item ~= "init.lua") then
                    ITEM = meta();
                    ITEM.UniqueID = item:sub(1,-5):lower();
                    ITEM.Category = newcat;
                    includecs(path..filename.."/"..item);
                    ITEM:Register();
                    str = str..", "..ITEM.UniqueID;
                    count = count + 1;
                end
            end
            str = str:sub(3);
            total = total + count;
            MsgN(" Loaded category '", CAT.Name, "' with ", count, " items:\n  ", str);
        end
    end
    MsgN("Applejack: Loading items from plugins:");
    local plugins = {};
    for _, plugin in pairs(GM.Plugins) do
        if (plugin._HasItems) then
            plugins[plugin] = plugin.FullPath .. "/items/";
        end
    end
    MsgN(" Looking for bases.");
    for plugin, path in pairs(plugins) do
        if (not file.ExistsInLua(path .. "base")) then
            continue;
        end
        MsgN("  Found bases in " .. plugin.Name .. "!");
        for _, filename in pairs(file.Find(path.."base/*.lua", "LUA")) do
            if (not validfile(filename)) then
                continue;
            end
            ITEM = meta();
            ITEM.Name = "NULL"; -- For the search
            includecs(path.."base/"..filename);
            ITEM.UniqueID = filename:sub(1,-5);
            ITEM:Register();
            MsgN("   Loaded item base '"..ITEM.UniqueID.."'");
        end
    end

    MsgN(" Looking for items.");
    local spath, uid, verb;
    for plugin, path in pairs(plugins) do
        MsgN("  Looking in " .. plugin.Name);
        files, folders = file.Find(path.."*", "LUA");
        for _, filename in pairs(folders) do
            if (not (validfile(filename) and not filename:find('.',1,true)) or filename == "base") then
                continue;
            end
            spath = path .. filename 
            uid = filename:lower();
            if (file.ExistsInLua(spath .. "/init.lua")) then
                -- redef the cat3g0ry.
                CAT = {};
                CAT.UniqueID = uid;
                includecs(path..filename.."/init.lua");
                local reg = true;
                for index, data in pairs(cats) do
                    if (data.UnqiueID == CAT.UniqueID) then
                        cats[index] = CAT;
                        CAT.Index = data.Index;
                        reg = false;
                        verb = "Redefined"
                    end
                end
                if (reg) then
                    _E['CATEGORY_'..string.upper(filename)] = registerCategory(CAT);
                    verb = "Created"
                end
            else
                CAT = self:GetCategory(uid);
                if (not CAT) then
                    ErrorNoHalt("Can't find non existant category ", uid, " in plugin ", plugin.Name, "!\n");
                    continue;
                end
                verb = "Enlivened"
            end
            str, count = "", 0;
            for _, item in pairs(file.Find(spath .. "/*.lua", "LUA")) do
                if (item == "init.lua" or not validfile(item)) then
                    continue;
                end
                uid = item:sub(1,-5):lower();
                -- Allow fiddling with existing items. 
                ITEM = GM.Items[uid] or meta();
                ITEM.UniqueID = item:sub(1,-5):lower();
                ITEM.Category = CAT.Index;
                includecs(path..filename.."/"..item);
                ITEM:Register();
                str = str..", "..ITEM.UniqueID;
                count = count + 1;
            end
            str = str:sub(3);
            total = total + count;
            MsgN("   ", verb, " category '", CAT.Name, "' with ", count, " items:\n    ", str);
        end
    end
    ITEM,CAT = nil;
    MsgN("Applejack: Loaded ", total, " items in total.");
    MsgN();
end

---
-- Gets an item by it's ID or name
-- @param id What to look for
-- @return The item you wanted or nil
function GM:GetItem(id)
    -- If we're passed a valid UniqueID, then return the item
    if (self.Items[id]) then
        return self.Items[id];
    end
    local res, len;
    -- Otherwise, we're looking for part of a name.
    id = id:lower();
    for _,data in pairs(self.Items) do
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

-- Concommand for debug
if SERVER then
    concommand.Add("cider_reload_items",function(ply)
        if (IsValid(ply) and not ply:IsSuperAdmin()) then return end
        GM:LoadItems();
    end)
elseif GetConVarNumber("developer") > 0 then -- Don't want the peons to get this command.
    concommand.Add("cider_reload_items_cl",function()
        GM:LoadItems();
    end)
end

function registerCategory(cat) -- meow
    cat.Index = index;
    cats[index] = cat;
    index = index + 1;
    return cat.Index;
end

---
-- Returns a category based on it's ID or name
-- @param id What to look for
-- @return The category you wanted or nil
function GM:GetCategory(id)
    -- If we're passed a valid id, return the category
    local nid = tonumber(id);
    if (nid and cats[nid]) then
        return cats[nid];
    end
    local res, len;
    -- Otherwise, we're looking for part of a name.
    id = tostring(id):lower();
    for _, data in pairs(cats) do
        if (id == data.UniqueID) then
            return data;
        elseif (data.Name:lower():find(id)) then
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
    return res;
end
