
include( "admin_buttons.lua" )
include( "vote_button.lua" )

local PANEL = {}

function PANEL:Init()

	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}

	self.btnKick = vgui.Create( "PlayerKickButton", self )
	self.btnBan = vgui.Create( "PlayerBanButton", self )
	self.btnPBan = vgui.Create( "PlayerPermBanButton", self )
	self.btnDem = vgui.Create( "PlayerDemoteButton", self )
end

function PANEL:SetInfo( column, k, v )

	if ( not v or v == "" ) then v = "N/A" end

	if ( not self.InfoLabels[ column ][ k ] ) then

		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "DLabel", self )
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "DLabel", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self:InvalidateLayout()

	end

	self.InfoLabels[ column ][ k ].Value:SetText( v )
	return true

end


function PANEL:SetPlayer( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

function PANEL:UpdatePlayerData()

	if (not self.Player) then return end
	if ( not self.Player:IsValid() ) then return end

	self:SetInfo( 2, "Props:", self.Player:GetCount( "props" ) + self.Player:GetCount( "ragdolls" ) + self.Player:GetCount( "effects" ) )
	self:SetInfo( 2, "HoverBalls:", self.Player:GetCount( "hoverballs" ) )
	self:SetInfo( 2, "Thrusters:", self.Player:GetCount( "thrusters" ) )
	self:SetInfo( 2, "Balloons:", self.Player:GetCount( "balloons" ) )
	self:SetInfo( 2, "Buttons:", self.Player:GetCount( "buttons" ) )
	self:SetInfo( 2, "Dynamite:", self.Player:GetCount( "dynamite" ) )
	self:SetInfo( 2, "SENTs:", self.Player:GetCount( "sents" ) )

	self:InvalidateLayout()

end

function PANEL:ApplySchemeSettings()

	for _k, column in pairs( self.InfoLabels ) do

		for k, v in pairs( column ) do

			v.Key:SetFGColor( 0, 0, 0, 100 )
			v.Value:SetFGColor( 0, 70, 0, 200 )

		end

	end

end

function PANEL:Think()

	if ( self.PlayerUpdate and self.PlayerUpdate > CurTime() ) then return end
	self.PlayerUpdate = CurTime() + 0.25

	self:UpdatePlayerData()

end

function PANEL:PerformLayout()

	local x = 5

	for colnum, column in pairs( self.InfoLabels ) do

		local y = 0
		local RightMost = 0

		for k, v in pairs( column ) do

			v.Key:SetPos( x, y )
			v.Key:SizeToContents()

			v.Value:SetPos( x + 70 , y )
			v.Value:SizeToContents()

			y = y + v.Key:GetTall() + 2

			RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )

		end

		--x = RightMost + 10
		x = x + 300

	end

	if ( not self.Player or
		 self.Player == LocalPlayer() or
		 not LocalPlayer():IsAdmin() ) then

		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )

	else

		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )

		self.btnKick:SetPos( self:GetWide() - 52 * 3, 80 )
		self.btnKick:SetSize( 48, 20 )

		self.btnBan:SetPos( self:GetWide() - 52 * 2, 80 )
		self.btnBan:SetSize( 48, 20 )

		self.btnPBan:SetPos( self:GetWide() - 52 * 1, 80 )
		self.btnPBan:SetSize( 48, 20 )
	end
	if not IsValid(self.Player) or self.Player == LocalPlayer() or not hook.Call("PlayerCanDemote",GAMEMODE,LocalPlayer(),self.Player) then
		self.btnDem:SetVisible( false )
	else
		self.btnDem:SetVisible( true )

		self.btnDem:SetPos( self:GetWide() - 52 * 4, 80 )
		self.btnDem:SetSize( 48, 20 )
	end


	--[[for k, v in ipairs( self.VoteButtons ) do

		v:InvalidateLayout()
		v:SetPos( self:GetWide() -  k * 25, 0 )
		v:SetSize( 20, 32 )

	end]]--

end

function PANEL:Paint()
	return true
end


vgui.Register( "ScorePlayerInfoCard", PANEL, "Panel" )
