--[[
Name: "cl_laws.lua".
	~ Applejack ~
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	-- self:SetText(GM.Config["Laws"]);
end

-- TODO: Rewrite this towering pile of shit.
local lteam = -1;
function PANEL:Think()
	if (lpl:Team() ~= lteam) then
		cider.laws.update = true;
		lteam = lpl:Team();
	end
	if not cider.laws.update then return end
	cider.laws.update = false

	self:Clear();
	self:SetText(GM.Config["Laws"] .. table.concat(cider.laws.stored, "\n"));

	if LocalPlayer():IsAdmin() or LocalPlayer():Team() == TEAM_MAYOR then
		local button = vgui.Create("DButton", self);
		button._NextPress = CurTime()
		button:SetText("Edit");
		button.DoClick = function()
			local EditPanel = vgui.Create( "DFrame" )
			EditPanel:SetPos( (ScrW()- 400)/2,(ScrH() -500)/2 )
			EditPanel:SetSize( 400 ,265 )
			EditPanel:SetTitle( "Edit the City Laws" )
			EditPanel:SetVisible( true )
			EditPanel:SetDraggable( true )
			EditPanel:ShowCloseButton( true )
			EditPanel:MakePopup()
			boxes = {}
			y = 28
			for i = 1,10 do
				boxes[i] = vgui.Create("DTextEntry",EditPanel)
				boxes[i]:SetPos(10,y)
				boxes[i]:SetValue(cider.laws.stored[i])
				boxes[i]:SetSize(EditPanel:GetWide()-20,16)
				y = y + boxes[i]:GetTall() + 5
			end
			local savebutton = vgui.Create("DButton",EditPanel)
			savebutton:SetText("Save")
			savebutton.DoClick = function()
				local tab = {}
				local diff = false
				for k,v in ipairs(boxes) do
					tab[k] = v:GetValue()
					if tab[k] ~= cider.laws.stored[k] then
						diff = true
					end
				end
				if diff then
					datastream.StreamToServer( "cider_Laws",tab)
				end
				EditPanel:Close()
			end
			savebutton:SetPos(EditPanel:GetWide()-savebutton:GetWide()-10,y)
		end
		button:Dock(TOP);
	end
end

-- Register the panel.
vgui.Register("cider_Laws", PANEL, "MSTextPanel");
