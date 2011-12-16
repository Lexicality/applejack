--[[
    ~ MSAccessList ~
    ~ Moonshine ~
--]]

-- Vars
local menu;

-- Util
local function verifyPos()
    -- Ensure they're where they were when they opened the menu.
    if (lpl:GetPos() == lpl._AccessMenuOpenPos) then
        return true;
    end
    -- They've moved. This probably breaks everything so give up
    menu:Close();
    menu:Remove();
    gui.EnableScreenClicker(false); 
    return false;
end

local itemfunction;
-- Button functions
do
    local function btn(what, how)
        local uid;
        if (what.IsPlayer) then
            if (IsValid(what)) then
                uid = what:UniqueID();
            end
        else
            uid = what.UniqueID;
        end
        if (uid) then
            RunConsoleCommand("mshine", "access", how, uid);
        end
    end
    local function giveAccess(what)
        btn(what, "give");
    end
    local function takeAccess(what)
        btn(what, "take");
    end
    function itemfunction(panel, item)
        local name, desc, mdl
        if (item.IsPlayer) then
            name = item:GetName();
            desc = "TODO! Details - Clan";
            mdl  = item:GetModel();
        else
            name = item.Name;
            desc = item.Description;
            mdl  = item.Model;
        end
        panel:SetName(name);
        panel:SetDescription(desc);
        panel:SetPortrait(mdl);
        panel:AddButton("Give Access", giveAccess);
        panel:AddButton("Take Access", takeAccess);
    end
end

local function getList(panel)
    return panel._AccessList
end

local function formatPlayerList(list)
    local res = {};
    local trans = {};
    for id, data in pairs(GM.Teams) do
        res[data.Name] = {};
        trans[id] = data.Name;
    end
    
    for _, ply in pairs(list) do
        local id = trans[ply:Team()];
        if (not id and res[id]) then
            continue;
        end
        table.insert(res[id], ply);
    end

    return res;
end

local function formatTeams(list)
    local res = {};
    
    for _, data in pairs(GM.Groups) do
        local gangs = {};
        for _, data in (data.Gangs) do
            gangs[data.Name] = {};
        end
        gangs["Unaffiliated"] = {};
        res[data.Name] = gangs;
    end

    for _, id in pairs(list) do
        local data = GM.Teams[id];
        if (not data and data.Group) then
            continue;
        end
        if (data.Gang) then
            res[data.Group.Name][data.Gang.Name] = data;
        else
            res[data.Group.Name]["Unaffiliated"] = data;
        end
    end

    return res;
end

local function formatGroups(list)
    local res = {};

