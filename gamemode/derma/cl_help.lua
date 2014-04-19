--[[
Name: "cl_help.lua".
	~ Applejack ~
--]]

local PANEL = {};

function PANEL:Init()
	-- We need to load the current help into our items list.
	self:Reload();
end

-- Reload the help text.
function PANEL:Reload()
	self:Empty();
	local sections = {};

	for title, text in pairs(cider.help.stored) do
		local text2 = {};
		for _, data in ipairs(text) do
			table.insert(text2, data.text);
		end
		table.insert(sections, {
			title = title;
			text  = text2;
		} );
	end

	self:CreateChildren(sections);
	self:InvalidateLayout(true);
end

-- Register the panel.
vgui.Register("cider_Help", PANEL, "MSTextPanel");
