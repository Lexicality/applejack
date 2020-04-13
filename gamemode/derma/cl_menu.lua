--
-- "cl_menu.lua"
-- ~ Applejack ~
--
cider.menu = {};
cider.menu.tabs = {};
cider.menu.open = nil;
local width = 700
if ScrW() > width then
	cider.menu.width = width;
else
	cider.menu.width = ScrW()
end
cider.menu.height = ScrH()-40;

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle("Main Menu");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	self:ShowCloseButton(false);

	-- Create the close button.
	self.close = vgui.Create("DButton", self);
	self.close:SetText("Close");
	self.close.DoClick = function(self) cider.menu.toggle(); end

	-- Create the tabs property sheet.
	self.tabs = vgui.Create("DPropertySheet", self);
	local function addTab(name, panel, icon)
		local data = {
			Name  = name;
			Panel = vgui.Create(panel);
			Icon  = "icon16/" .. icon .. ".png"
		};
		self.tabs:AddSheet(data.Name, data.Panel, data.Icon);
		cider.menu.tabs[name] = data;
	end

	-- Add the sheets for the other menus to the property sheet.
	addTab("Character", "cider_Character", "user");
	addTab("Help",      "cider_Help",      "page");
	addTab("Laws",      "cider_Laws",      "world");
	addTab("Rules",     "cider_Rules",     "exclamation");
	addTab("Inventory", "cider_Inventory", "application_view_tile");
	addTab("Store",     "cider_Store",     "box");
	addTab("Changelog", "cider_Changelog", "plugin");
	addTab("Donate",    "cider_Donate",    "heart");
	addTab("Credits",   "cider_Credits",   "group");
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:SetVisible(cider.menu.open);
	self:SetSize(cider.menu.width, cider.menu.height);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);

	-- Set the size and position of the close button.
	self.close:SetSize(48, 16);
	self.close:SetPos(self:GetWide() - self.close:GetWide() - 4, 3);

	-- Stretch the tabs to the parent.
	self.tabs:StretchToParent(4, 28, 4, 4);

	-- Size To Contents.
	self:SizeToContents();

	-- Perform the layout of the main frame.
	DFrame.PerformLayout(self);
end

-- Register the panel.
vgui.Register("cider_Menu", PANEL, "DFrame");

-- A function to toggle the menu.
function cider.menu.toggle(msg)
	if (GAMEMODE.playerInitialized) then
		cider.menu.open = not cider.menu.open;

		-- Toggle the screen clicker.
		gui.EnableScreenClicker(cider.menu.open);

		-- Check if the main menu exists.
		if (cider.menu.panel) then
			cider.menu.panel:SetVisible(cider.menu.open);
		else
			cider.menu.panel = vgui.Create("cider_Menu");
			cider.menu.panel:MakePopup();
		end
	end
end

-- Hook the usermessage to toggle the menu from the server.
usermessage.Hook("cider_Menu", cider.menu.toggle);
