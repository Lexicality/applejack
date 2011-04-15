--[[
	~ Clientside Menu Library ~
	~ Moonshine ~
--]]

do return end -- NOT TODAY BRIGHT EYES

---
-- Handles all menus and shit yo
local menu = {
	tabs = {}; -- The tab panels, [title] = PANEL
	panel = nil; -- The menu's derma panel
	open = false; -- The menu's state (Doesn't take animation times into consideration)
	animating = false; -- If the menu is currently animating (either in or out)
	animdir = 0; -- The menu's animation direction. 0 = not, 1 = in, 2 = out.
};
GM.Menu = menu; -- All accessable and that yo

local menuTabs = {}

---
-- Adds a tab to the menu. Do not call once the menu has been created.
-- @param name The name registered to the element
-- @param title The title to display on the tab
-- @param silkicon the icon to display on the tab
function GM:RegisterMenuTab(name, title, silkicon)
	if (menu.panel) then
		error("Called RegisterMenuTab after the menu exists!",2)
	end
	menuTabs[name] = {
		title = title;
		silkicon = silkicon;
	};
end

---
-- Toggles the menu.
function GM:ToggleMenu()
	if (not self.playerInitialized) then return; end
	if (not menu.panel) then
		menu.panel = vgui.Create("Main Menu (mshine)");
		menu.panel:MakePopup();
	end
	menu.open = not menu.open;
	gui.EnableScreenClicker(menu.open);
	menu.panel:SetVisible(menu.open);
end
local function menumsg()
	GM:ToggleMenu();
end
usermessage.Hook("GM:ToggleMenu", menumsg);


---
-- Menu dermas
local P = {};
-- panel stuff goes here
vgui.Register("Main Menu (mshine)", P, "DFrame");