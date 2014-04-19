--[[
Name: "cl_rules.lua".
	~ Applejack ~
--]]
local PANEL = {};

function PANEL:Init()
	local header = vgui.Create("cider_Rules_Header", self);
	header.label:SetText("Ventmob Roleplay Rules");
	header:SetHeight(header:GetTall()*3)
	header:Dock(TOP);
	self:SetText(GM.Config["Rules"]);
end

vgui.Register("cider_Rules", PANEL, "MSTextPanel");


-- http://facepunch.com/showthread.php?t=1220579
surface.CreateFont("MenuLarge", {
	font = "Verdana",
	size = 15,
	weight = 600,
	antialias = true,
});

local PANEL = {};

function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetDark( true );
	self.label:SetFont("MenuLarge");
	-- self.label:SetTextColor( color_black );
	self.label:SizeToContents();
end

function PANEL:PerformLayout()
	self.label:SetPos(self:GetWide() / 2 - self.label:GetWide() / 2, self:GetTall() / 2 - self.label:GetTall() / 2);
	self.label:SizeToContents();
end

vgui.Register("cider_Rules_Header", PANEL, "DPanel");
