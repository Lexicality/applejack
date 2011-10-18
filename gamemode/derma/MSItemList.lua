--[[
    ~ Player List ~
    ~ Moonshine ~
--]]

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

function PANEL:UpdateList()
    local list = self:m_fGetList();
    -- Wipe existing items
    self:Clear(true);
    -- Grab the new ones
    local panel;
    for _, item in pairs(list) do
        panel = vgui.Create("MSItemList_Item", self);
        panel:SetItemFunction(self.m_fItemFunc);
        panel:SetItem(item);
        self:AddItem(panel);
    end
    -- Update erryting
    self:PerformLayout();
    self.m_iLastUpdated = RealTime();
end

function PANEL:Think()
    if (self.m_bAutoUpdate and self.m_iLastUpdated < RealTime() - self.m_iUpdateInterval) then
        self:UpdateList();
    end
end

derma.DefineControl("MSItemList", "Container for Moonshine object lists", PANEL, "DPanelList");

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
    PCallError(btn.m_fCallback, btn.m_tItem);
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

derma.DefineControl("MSItemList_Item", "Object for Moonshine object lists", PANEL, "DPanel");
