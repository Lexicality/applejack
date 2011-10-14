--[[
    ~ Player List ~
    ~ Moonshine ~
--]]

local PANEL = {};
AccessorFunc(PANEL, "m_fGetList",           "ListFunction"                  );
AccessorFunc(PNAEL, "m_fItemFunc",          "Itemfunction"                  );
AccessorFunc(PANEL, "m_bAutoUpdate",        "AutoUpdate",       FORCE_BOOL  );
AccessorFunc(PANEL, "m_iUpdateInterval",    "UpdateInterval",   FORCE_NUMBER);

PANEL.m_iLastUpdated = 0;

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
    if (self.m_bAutoUpdate and self.m_iLastUpdated < RealTime()) then
        self:UpdateList();
    end
end

derma.DefineControl("MSItemList", "Container for Moonshine object lists", PANEL, "DPanelList");

local PANEL = {};

AccessorFunc(PANEL, "m_fItemFunc",  "ItemFunction");

PANEL.m_tButtons = {};

function PANEL:Init()
    self.m_pPortrait = vgui.Create("Spawnicon");
    self.m_pLabel    = vgui.Create("DLabel");
end

function PANEL:SetPortrait(model)
    self.m_pPortrait:SetModel(model);
end

function PANEL:SetLabel(str)
    self.m_pLabel:SetText(str);
end

function PANEL:AddButton(str, func)
    -- TODO
end

function PANEL:SetItem(item)
    self.Item = item;
    self:m_fItemFunc(item);
end

derma.DefineControl("MSItemList_Item", "Object for Moonshine object lists", PANEL, "DPanel");
