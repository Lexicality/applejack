--[[
	~ MSTextPanel ~
	~ Moonshine ~
--]]

local PANEL = {};

function PANEL:Init()
	self.items = {};
	-- Turn engine drawing back on
	self:SetPaintBackgroundEnabled( true )
	self:SetPaintBorderEnabled( true )
	self:SetPaintBackground( true )
end

function PANEL:Empty()
	for _, item in pairs(self.items) do
		item:Remove();
	end
end

function PANEL:SplitIntoSections(text)
	local sections = {};
	local currSection = nil;
	for _, line in ipairs(string.Split(text, "\n")) do
		if (line ~= "") then
			if (line:sub(1,1) == "[" and line:sub(-1) == "]") then
				currSection = {
					title = line:sub(2, -2);
					text  = {};
				};
				table.insert(sections, currSection);
			elseif (not currSection) then
				error("Text does not start with a header entry!", 2);
			else
				table.insert(currSection.text, line);
			end
		end
	end
	return sections;
end

PANEL.ChildPanel = "MSTextPanelItem";

function PANEL:CreateChildren(sections)
	local child;
	for _, section in ipairs(sections) do
		child = vgui.Create(self.ChildPanel, self);
		child:SetLabel(section.title);
		child:Dock(TOP);
		for _, line in ipairs(section.text) do
			child:AddLine(line);
		end
		table.insert(self.items, child);
	end
end

function PANEL:SetText(text)
	local sections = self:SplitIntoSections(text);
	self:CreateChildren(sections);
	self:InvalidateLayout(true);
end

vgui.Register("MSTextPanel", PANEL, "DScrollPanel");


local PANEL = {};

function PANEL:Init()
	self.items = {};
end

function PANEL:AddLine(line)
	local sizer = vgui.Create( "DSizeToContents", self );
	sizer:SetSizeX( false );
	sizer:Dock( TOP );
	sizer:DockPadding( 0, 0, 0, 0 );
	sizer:InvalidateLayout();
	local label = vgui.Create("DLabel", sizer);

	label:SetDark( true );
	label:SetWrap( true );
	label:SetTextInset( 0, 0 );
	label:SetText( line );
	label:SetContentAlignment( 7 );
	label:SetAutoStretchVertical( true );
	label:DockMargin( 8, 0, 8, 8 );
	label:Dock(TOP);

	sizer.label = label;
	table.insert(self.items, sizer);
end

function PANEL:Empty()
	for _, panel in pairs(self.items) do
		panel:Remove();
	end
end

vgui.Register("MSTextPanelItem", PANEL, "DCollapsibleCategory");
