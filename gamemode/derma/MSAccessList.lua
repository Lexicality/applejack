--[[
    ~ MSAccessList ~
    ~ Moonshine ~
--]]

-- Vars
local menu;

-- Usage
local function CreateMenu(data)
    if (IsValid(menu)) then
        menu:Close();
        menu:Remove();
        menu = nil;
    end
    local width = 800;
    local height = ScrH() * 0.75;
    menu = vgui.Create("MSAccessList");
    menu:SetSize(width, height);
    menu:SetData(data);
    menu:MakePopup();
end

local function UpdateMenu(data)
    if (not IsValid(menu)) then
        MsgN("Sent an access menu update with no access menu open!");
        return;
    end
    menu:SetData(data);
end

if (net) then
    net.Receive("MS Access List", function()
        CreateMenu(net.ReadTable());
    end);
    net.Receive("MS Access List update", function()
        UpdateMenu(net.ReadTable());
    end);
else
    datastream.Hook("MS Access List", function(_,_,_, data)
        CreateMenu(data);
    end);
    datastream.Hook("MS Access List update", function(_,_,_, data)
        UpdateMenu(data);
    end);
end

----------------------------------------
----------------------------------------
----                                ----
----       Utility Functions        ----
----                                ----
----------------------------------------
----------------------------------------

-- Util
local function verifyPos()
    -- TODO: Put this in the think hook. Why is it out here??
    if (not IsValid(menu)) then
        return false;
    end
    -- Ensure they're where they were when they opened the menu.
    if (lpl:GetPos() == menu.OpenPos) then
        return true;
    end
    -- They've moved. This probably breaks everything so give up
    menu:Close();
    menu:Remove();
    gui.EnableScreenClicker(false); 
    return false;
end

-- Button functions
local takeFunction;
local giveFunction;
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
    local function itemfunction(panel, item)
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
    end
    function giveFunction(panel, item)
        itemfunction(panel, item);
        panel:AddButton("Give Access", giveAccess);
    end
    function takeFunction(panel, item)
        itemfunction(panel, item);
        panel:AddButton("Take Access", takeAccess);
    end
end

----------------------------------------
----------------------------------------
----                                ----
----      List Formatting           ----
----                                ----
----------------------------------------
----------------------------------------

local function sortfunc(a, b)
    return a.SortWeight < b.SortWeight or a.Name < b.Name;
end

local function sortname(a, b)
    return a:Name() < b:Name();
end

local function formatPlayerList(list)
    local res = {};
    local trans = {};
    for _, group in pairs(GM.Groups) do
        local data = {
            SortWeight = group.SortWeight;
        };
        for _, team in pairs(group.Teams) do
            local arf = {
                SortWeight = team.SortWeight;
            };
            data[team.Name] = arf;
            trans[team.TeamID] = arf;
        end
        res[group.Name] = data;
    end

    for _, ply in pairs(list) do
        local data = trans[ply:Team()];
        if (not data) then
            continue;
        end
        table.insert(data, ply);
    end

    for name, gdata in pairs(res) do
        local hasdata = false;
        for name, tdata in pairs(gdata) do
            if (name == "SortWeight") then
                continue;
            end
            if (#tdata > 0) then
                hasdata = true;
                table.sort(tdata, sortname);
            else
                gdata[name] = nil;
            end
        end
        if (not hasdata) then
            res[name] = nil;
        end
    end

    return res;
end

local function formatTeamList(list)
    local res = {};
    local trans = {};
    
    for _, group in pairs(GM.Groups) do
        local gangs = {
            SortWeight = group.SortWeight;
        };
        for _, gang in (data.Gangs) do
            local teams = {
                SortWeight = gang.SortWeight;
            };
            for _, team in pairs(gang.Teams) do
                trans[team.TeamID] = teams;
            end
            gangs[gang.Name] = teams;
        end
        teams = {
            SortWeight = 10;
        }
        for _, team in pairs(group.Teams) do
            if (not trans[team.TeamID]) then
                trans[team.TeamID] = teams;
            end
        end
        gangs["Unaffiliated"] = teams;
        res[data.Name] = gangs;
    end

    for _, id in pairs(list) do
        local team = GM.Teams[id];
        if (not team) then
            continue;
        end
        local data = trans[team.TeamID];
        if (not data) then
            continue;
        end
        table.insert(data, team);
    end

    for name, gdata in pairs(res) do
        local hasdata = false;
        for name, tdata in pairs(gdata) do
            if (name == "SortWeight") then
                continue;
            end
            if (#tdata > 0) then
                hasdata = true;
                table.sort(tdata, sortfunc);
            else
                gdata[name] = nil;
            end
        end
        if (not hasdata) then
            res[name] = nil;
        end
    end

    return res;
end

local function formatGangList(list)
    local groups = {};
    local gangs = {};
    for _, id in pairs(list) do
        if (id < 0) then
            groups[-id] = true;
        else
            gangs[id] = true;
        end
    end
    local res = {};
    for _, group in pairs(GM.Groups) do
        local data = {
            SortWeight = group.SortWeight;
        };
        for _, gang in pairs(group.Gangs) do
            if (gangs[gang.GangID]) then
                table.insert(data, gang);
            end
        end
        if (groups[group.GroupID]) then
            table.insert(data, group);
        end
        if (#data > 0) then
            res[group.Name] = data;
        end
    end
    return ret;
end

local function prepPlayers(data)
    local ret = {};
    ret.Peons = formatPlayerList(data.Players.Peons);
    ret.Peers = formatPlayerList(data.Players.Peers);
    return ret;
end

local function prepTeams(data)
    local ret = {};
    ret.Peons = formatTeamList(data.Teams.Peons);
    ret.Peers = formatTeamList(data.Teams.Peers);
    return ret;
end

local function prepGangs(data)
    local ret = {};
    ret.Peons = formatGangList(data.Gangs.Peons);
    ret.Peers = formatGangList(data.Gangs.Peers);
    return ret;
end
----------------------------------------
----------------------------------------
----                                ----
----     Main Access List Derma     ----
----                                ----
----------------------------------------
----------------------------------------
local tabPane;

PANEL = {};

function PANEL:Initialize()
    -- To detect if the player gets knocked out of the way
    -- TODO: Far better thing to do would be to check if they're still looking at the right entity.
    self.OpenPos = lpl:GetPos();
    -- Master DFrame stuffs
    self:SetTitle("Access Menu");
    self:SetBackgroundBlur(true);
    self:SetDeleteOnClose(true);
    -- We're replacing the tiny X with a bigger CLOSE button
    self:ShowCloseButton(false);
    -- Creation
    self.Players = vgui.CreateFromTable(tabPane, self);
    self.Panes = vgui.Create("DPropertySheet", self);
    self.Teams = vgui.CreateFromTable(tabPane, self);
    self.Gangs = vgui.CreateFromTable(tabPane, self);
    -- Strip above the tabs etc.
    self.TopBackground = vgui.Create("DPanel", self);
    local bkgrnd = self.TopBackground;
    bkgrnd.CloseButton = vgui.Create("DButton", bkgrnd);
    bkgrnd.SellButton = vgui.Create("DButton", bkgrnd);
    bkgrnd.SetNameButton = vgui.Create("DButton", bkgrnd);
    bkgrnd.SetNameBox = vgui.Create("DTextEntry", bkgrnd);

    -- Initialization
    self.Panes:AddSheet("Players", self.Players);
    self.Panes:AddSheet("Teams", self.Teams);
    self.Panes:AddSheet("Gangs", self.Gangs);
    bkgrnd.CloseButton:SetText("Close");
    bkgrnd.SellButton:SetText("Sell");
    bkgrnd.SetNameButton:SetText("Set Name");

    -- Carlbocks
    do
        local this = self;
        local function doclose()
            this:Close();
            gui.EnableScreenClicker(false);
        end
        local function finishsell()
            RunConsoleCommand("mshine", "entity", "sell");
            doclose();
        end
        local function dosell()
            local menu = DermaMenu();
            menu:AddOption("No");
            menu:AddOption("yes", finishsell);
            menu:Open();
        end
        local function doname()
            local text = bkgrnd.SetNameBox:GetValue();
            if (text == "") then
                return;
            end
            text = string.sub(text, 1, 32);
            RunConsoleCommand("mshine", "entity", "rename", text);
            bkgrnd.SetNameBox:SetValue("");
            bkgrnd.SetNameBox:KillFocus();
        end
        bkgrnd.CloseButton.DoClick = doclose;
        bkgrnd.SellButton.DoClick = dosell;
        bkgrnd.SetNameBox.OnEnter = doname;
        bkgrnd.SetNameButton.DoClick = doname;
    end

    -- Positioning
    self.TopBackground:Dock(TOP);
    self.Panes:Dock(FILL);
end

function PANEL:SetData(data)
    self.Players:SetData(prepPlayers(data));
    self.Teams:SetData(prepTeams(data));
    self.Gangs:SetData(prepGangs(data));
end

function PANEL:PerformLayout()
    -- TODO
end

vgui.Register("MSAccessList", PANEL, "DFrame");

PANEL = {};

function PANEL:Initialize()
    local peerlist = vgui.Create("MSItemList", self);
    local peonlist = vgui.Create("MSItemList", self);

    -- Layout
    peerlist:Dock(LEFT);
    peonlist:Dock(RIGHT);
    -- Save the lists for later
    self.Peers = peerlist;
    self.Peons = peonlist;
end

function PANEL:PerformLayout()
    local width = (self:GetWide() / 2) - 8
    self.Peers:SetWide(width);
    self.Peons:SetWide(width);
    self.Peers:InvalidateLayout();
    self.Peons:InvalidateLayout();
end

function PANEL:SetData(data)
    self.Peers:SetItems(data.Peers);
    self.Peons:SetItems(data.Peons);
end

tabPane = vgui.RegisterTable(PANEL, "DPanel");
