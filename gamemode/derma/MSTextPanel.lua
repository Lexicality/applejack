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

function PANEL:SetText(text)

	local activeItem = nil;

	for _, line in pairs(string.Split(text, "\n")) do
		if (line ~= "") then
			if (line:sub(1,1) == "[" and line:sub(-1) == "]") then
				activeItem = vgui.Create("MSTextPanelItem", self);
				activeItem:SetLabel(line:sub(2, -2));
				activeItem:Dock(TOP);
				table.insert(self.items, activeItem);
			elseif (not activeItem) then
				error("Text does not start with a header entry!", 2);
			else
				activeItem:AddLine(line);
			end
		end
	end
	print("Invalid layout time")
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
