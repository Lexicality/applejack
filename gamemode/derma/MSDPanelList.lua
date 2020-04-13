local PANEL = {}

AccessorFunc( PANEL, "m_bSizeToContents", 		"AutoSize" )
AccessorFunc(PANEL, "m_fAnimTime",				"AnimTime")
AccessorFunc(PANEL, "m_fAnimEase",				"AnimEase")

AccessorFunc(PANEL, "Spacing",		"Spacing")
AccessorFunc(PANEL, "Padding",		"Padding")

function PANEL:Init()
	self.pnlCanvas	= vgui.Create("DPanel", self)
	self.pnlCanvas:SetPaintBackground(false)
	self.pnlCanvas.OnMousePressed = function(self, code) self:GetParent():OnMousePressed(code) end
	self.pnlCanvas.OnChildRemoved = function() self:OnChildRemoved() end
	self.pnlCanvas:SetMouseInputEnabled(true)
	self.pnlCanvas.InvalidateLayout = function() self:InvalidateLayout() end
	self.Items = {}
	self.YOffset = 0
	self.m_fAnimTime = 0
	self.m_fAnimEase = -1 -- means ease in out
	self.m_iBuilds = 0

	self:SetSpacing(0)
	self:SetPadding(0)
	self:SetAutoSize(false)
	self:SetDrawBackground(true)
	self:SetBottomUp(false)
	self:SetNoSizing(false)

	self:SetMouseInputEnabled(true)

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
end

function PANEL:SizeToContents()
	self:SetSize(self.pnlCanvas:GetSize())
end

function PANEL:GetItems()
	return self.Items
end

function PANEL:EnableVerticalScrollbar()
	if (not self.VBar) then
		self.VBar = vgui.Create("DVScrollBar", self)
	end
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:Clear(bDelete)
	for k, panel in pairs(self.Items) do
		self.Items[k] = nil

		if (not IsValid(panel)) then
			continue
		end

		panel:SetVisible(false)
		if (bDelete) then
			panel:Remove()
		end
	end
end

function PANEL:AddItem(item, strLineState, where)
	if (not IsValid(item)) then
		return
	end
	table.RemoveByValue(self.Items, item)
	item:SetVisible(true)
	item:SetParent(self:GetCanvas())
	item.m_strLineState = strLineState or item.m_strLineState
	item:SetSelectable(self.m_bSelectionCanvas)

	if (where) then
		table.insert(self.Items, where, item)
	else
		table.insert(self.Items, item)
	end

	self:InvalidateLayout()
end

function PANEL:InsertBefore(before, insert, strLineState)
	local key = table.KeyFromValue(self.Items, before)
	key = key or 1 -- If the key doesn't exist, go to the top
	self:AddItem(insert, strLineState, key)
end

function PANEL:InsertAfter(before, insert, strLineState)
	local key = table.KeyFromValue(self.Items, before)
	key = key and key + 1 or nil -- If the key exists, go one after. If not, go to the back.
	self:AddItem(insert, strLineState, key)
end

function PANEL:InsertAtTop(insert, strLineState)
	self:AddItem(insert, strLineState, 1)
end

function PANEL:InsertAtBottom(insert, strLineState)
	self:AddItem(insert, strLineState)
end

function PANEL:RemoveItem(item, bDontDelete)
	if (table.RemoveByValue(self.Items, item)) then
		if (not bDontDelete) then
			item:Remove()
		end

		self:InvalidateLayout()
	end
end

function PANEL:CleanList()
	local keys = {}

	for k, panel in pairs(self.Items) do
		if (not IsValid(panel) or panel:GetParent() ~= self.pnlCanvas) then
			table.insert(keys, k)
		end
	end

	for k, key in pairs(keys) do
		table.Remove(self.Items, key)
	end
end

function PANEL:Rebuild()
	local Offset = 0
	self.m_iBuilds = self.m_iBuilds + 1

	self:CleanList()

	for k, panel in ipairs(self.Items) do
		if (not panel:IsVisible()) then
			continue
		end

		--panel:SetSize(self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall())
		panel:SetWidth(self:GetCanvas():GetWide() - self.Padding * 2)

		if (self.m_fAnimTime > 0 and self.m_iBuilds > 1) then
			panel:MoveTo(self.Padding, self.Padding + Offset, self.m_fAnimTime, self.m_fAnimEase)
		else
			panel:SetPos(self.Padding, self.Padding + Offset)
		end

		-- Changing the width might ultimately change the height
		-- So give the panel a chance to change its height now,
		-- so when we call GetTall below the height will be correct.
		-- True means layout now.
		panel:InvalidateLayout(true)

		Offset = Offset + panel:GetTall() + self.Spacing
	end

	Offset = Offset + self.Padding

	self:GetCanvas():SetTall(Offset + self.Padding - self.Spacing)
end

function PANEL:OnMouseWheeled(dlta)
	if (self.VBar) then
		return self.VBar:OnMouseWheeled(dlta)
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "PanelList", self, w, h)
	return true
end

function PANEL:OnVScroll(iOffset)
	self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local YPos = 0

	if (not self.Rebuild) then
		debug.Trace()
	end

	self:Rebuild()

	if (self.VBar and not self.m_bSizeToContents) then
		self.VBar:SetPos(self:GetWide() - 13, 0)
		self.VBar:SetSize(13, self:GetTall())
		self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
		YPos = self.VBar:GetOffset()

		if (self.VBar.Enabled) then
			Wide = Wide - 13
		end
	end

	self.pnlCanvas:SetPos(0, YPos)
	self.pnlCanvas:SetWide(Wide)

	self:Rebuild()

	if (self.m_bSizeToContents) then
		self:SetTall(self.pnlCanvas:GetTall())
		self.pnlCanvas:SetPos(0, 0)
	end
end


function PANEL:OnChildRemoved()
	self:CleanList()
	self:InvalidateLayout()
end

function PANEL:ScrollToChild(panel)
	local x, y = self.pnlCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()

	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end


function PANEL:SortByMember(key, desc)
	desc = desc or true

	table.sort(self.Items, function(a, b)
		if (not desc) then
			a,b = b,a
		end

		if (a[key] == nil or b[key] == nil) then
			return false
		else
			return a[key] < b[key]
		end
	end)

	self:InvalidateLayout();
end

function PANEL:SortByFunction(func)
	table.sort(self.Items, func);
	self:InvalidateLayout();
end

derma.DefineControl("MSDPanelList", "A butchered version of DPanelList just for Moonshine", PANEL, "DPanel")
