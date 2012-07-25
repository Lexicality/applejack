--[[
    ~ Player List ~
    ~ Moonshine ~
--]]

local itempanel;
local PANEL = {};
AccessorFunc(PANEL, "m_fGetList",           "ListFunction"                  );
AccessorFunc(PNAEL, "m_fItemFunc",          "Itemfunction"                  );
AccessorFunc(PANEL, "m_bAutoUpdate",        "AutoUpdate",       FORCE_BOOL  );
AccessorFunc(PANEL, "m_iUpdateInterval",    "UpdateInterval",   FORCE_NUMBER);

PANEL.m_bAutoUpdate     = false;
PANEL.m_iUpdateInterval = 30 -- every 30 seconds
PANEL.m_iLastUpdated    = 0;

function PANEL:Init()
    self.BaseClass.Init(self);
    self:SetPadding(2);
    self:SetSpacing(3);
    self:EnableVerticalScrollbar();
end

local function dosort(a, b)
    return a.SortWeight < b.SortWeight or a.Name < b.Name;
end
---
-- Recursively loads headers so you can have a multi-level list
-- @usage tab should be either a table of numerically indexed 'items' (AKA anything),
--         or a string indexed table of tables which have the same format as the parent.
--        This allows you to have potentially unlimited levels of DCollapsableCategories,
--         though for sanity's sake I suggest no more than 3.
--        This does not support mixed headers and entries. A DCollapsableCategory can have
--         either headers or items in it. Using both will result in undefined behaviour.
-- @param list The DListPanel to add entries to
-- @param tab  The table with the entries to add
function PANEL:SetItems(list, tab)
    -- If this is a list of categories instead of a list of items
    if (#tab == 0) then
        local ordered = {};
        for name, tab in pairs(tab) do
            local info = {
                Name   = name;
                Weight = tab.SortWeight or 0;
                Data   = tab;
            }
            tab.SortWeight = nil;
            table.insert(ordered, info);
        end
        table.sort(ordered, dosort);

        for _, data in ipairs(ordered) do
            local header = vuil.Create("DCollapsableCategory", list);
            header:SetText(data.Name);
            header:SetSize(list:GetWide(), 50) -- 'parrently this has to be 50.
            list:AddItem(header);
            -- Yay for scope
            local list = vgui.Create("DPanelList", header);
            list:SetPadding(2);
            list:SetSpacing(3);
            list:SetAutoSize(2);
            header:SetContents(list);
            recursiveTable(list, data.Data);
        end
    else
        for _, item in ipairs(tab) do
            local entry = vgui.CreateFromTable(itempanel, list);
            entry:SetItemFunction(self.m_fItemFunc);
            entry:SetItem(item);
            list:AddItem(entry);
        end
    end
end

---
-- Wipes the current contents of the panel and rebuilds it from the list function.
-- Calling this manually resets the AutoUpdate timer if it is enabled, so the next automatic
--  update will be in UpdateInterval seconds, reguardless of the previous amount left on the timer.
function PANEL:UpdateContents()
    local list = self:m_fGetList();
    -- Wipe existing items
    self:Clear(true);
    -- Apply the new items
    self:RecursiveTabel(self, list);
    -- Update erryting
    self:PerformLayout();
    self.m_iLastUpdated = RealTime();
end

function PANEL:Think()
    if (self.m_bAutoUpdate and self.m_iLastUpdated < RealTime() - self.m_iUpdateInterval) then
        self:UpdateContents();
    end
end

derma.DefineControl("MSItemList", "Container for Moonshine object lists", PANEL, "DPanelList");

--
--
-- Item
--
--

local PANEL = {};

AccessorFunc(PANEL, "m_fItemFunc",  "ItemFunction");

PANEL.m_tButtons = {};

function PANEL:Init()
    self.m_pPortrait = vgui.Create("Spawnicon", self);
    self.m_pName     = vgui.Create("DLabel", self); -- TODO: Work out how to make this bold
    self.m_pLabel    = vgui.Create("DLabel", self);
end

function PANEL:SetPortrait(model)
    self.m_pPortrait:SetModel(model);
end

function PANEL:SetDescription(str)
    self.m_pLabel:SetText(str);
end

function PANEL:SetName(str)
    self.m_pName:SetText(str);
end

local function dbuttonpress(btn)
    --[[ Does this actually need error protection? Nothing will break if it does error.
    PCallError(btn.m_fCallback, btn.m_tItem);
    --]]
    btn.m_fCallback(btn.m_tItem);
end
function PANEL:AddButton(str, func)
    local btn = vgui.Create("DButton", self);
    btn:SetText(str);
    btn.DoClick     = dbuttonpress;
    btn.m_fCallback = func;
    btn.m_tItem     = self.Item;
    table.insert(self.m_tbuttons, btn);
    return btn;
end

function PANEL:PerformLayout()
    self.m_pName:SizeToContents();
    -- TODO: Work out how word-wrap work
    self.m_pDecsription:SizeToContents();
    local x, y = 4, 5
    -- Positions
    self.m_pPortrait:SetPos(x, y);
    x = x + self.m_pPortrait:GetWide() + 8;
    -- TODO: y should probably be worked out not set like this
    y = 4;
    self.m_pName:SetPos(x, y)
    y = 24;
    self.m_pDescription:SetPos(x, y);
    y = 47;
    for _, btn in pairs(self.m_tButtons) do
        btn:SetPos(x, y);
        x = x + btn:GetWide();
    end
end

function PANEL:SetItem(item)
    self.Item = item;
    self:m_fItemFunc(item);
end

itempanel = vgui.RegisterTable(PANEL, "DPanel");
