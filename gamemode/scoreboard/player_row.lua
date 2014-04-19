
include( "player_infocard.lua" )

surface.CreateFont("ScoreboardPlayerName" , {
	font		= "coolvetica";
	size		= 19;
	weight		= 500;
	antialias	= true;
	additive	= false;
})
surface.CreateFont("ScoreboardPlayerNameBig" , {
	font		= "coolvetica";
	size		= 22;
	weight		= 500;
	antialias	= true;
	additive	= false;
})

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local texRatings = {}
texRatings[ 'user' ] 	= Material( "icon16/user.png" )
texRatings[ 'mod' ] 	= Material( "icon16/emoticon_smile.png" )
texRatings[ 'donator' ] = Material( "icon16/heart.png" )
texRatings[ 'admin' ] 	= Material( "icon16/star.png" )
texRatings[ 'super' ] 	= Material( "icon16/shield.png" )
--surface.GetTextureID( "icon16/emoticon_smile.png" )
local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 36
	self:OpenInfo( false )

	self.infoCard	= vgui.Create( "ScorePlayerInfoCard", self )

	self.lblName 	= vgui.Create( "Label", self )
	self.lblFrags 	= vgui.Create( "Label", self )
	self.lblDeaths 	= vgui.Create( "Label", self )
	self.lblPing 	= vgui.Create( "Label", self )

	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )

	self.imgAvatar = vgui.Create( "AvatarImage", self )

	self:SetCursor( "hand" )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	if ( !IsValid( self.Player ) ) then return end

	local color = team.GetColor(self.Player:Team())
	-- Check if we're sliding
	if ( self.Open || self.Size ~= self.TargetSize ) then

		draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
		draw.RoundedBox( 4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color( 250, 250, 245, 255 ) )

		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2 )

	end

	draw.RoundedBox( 4, 0, 0, self:GetWide(), 36, color )

	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 36 )

	// This should be an image panel!
	surface.SetMaterial( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( self:GetWide() - 16 - 8, 36 / 2 - 8, 16, 16 )

	return true

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply

	self.infoCard:SetPlayer( ply )
	self.imgAvatar:SetPlayer( ply )

	self:UpdatePlayerData()

end

function PANEL:CheckRating( name, count )

	if ( self.Player:GetNetworkedInt( "Rating."..name, 0 ) > count ) then
		count = self.Player:GetNetworkedInt( "Rating."..name, 0 )
		self.texRating = texRatings[ name ]
	end

	return count

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !self.Player:IsValid() ) then return end
	local clan = "" if (self.Player:GetNetworkedString("Clan") ~= "") then clan = " ("..self.Player:GetNetworkedString("Clan")..")" end
	self.lblName:SetText( "["..self.Player:GetNetworkedString("Job").."] "..self.Player:Nick()..clan )
	self.lblName:SizeToContents()
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblPing:SetText( self.Player:Ping() )

	// Work out what icon to draw

	self.texRating = texRatings[ 'user' ]
	if self.Player:IsSuperAdmin() then
		self.texRating = texRatings['super']
	elseif self.Player:IsAdmin() then
		self.texRating = texRatings['admin']
	elseif self.Player:IsModerator() then
		self.texRating = texRatings['mod']
	elseif self.Player:GetNetworkedBool("Donator") then
		self.texRating = texRatings['donator']
	end
end



/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "ScoreboardPlayerNameBig" )
	self.lblFrags:SetFont( "ScoreboardPlayerName" )
	self.lblDeaths:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )

	self.lblName:SetFGColor( color_white )
	self.lblFrags:SetFGColor( color_white )
	self.lblDeaths:SetFGColor( color_white )
	self.lblPing:SetFGColor( color_white )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick( x, y )

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 36
	end

	self.Open = bool

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size ~= self.TargetSize ) then

		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()

	end

	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then

		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()

	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.imgAvatar:SetPos( 2, 2 )
	self.imgAvatar:SetSize( 32, 32 )

	self:SetSize( self:GetWide(), self.Size )

	self.lblName:SizeToContents()
	self.lblName:SetPos( 24, 2 )
	self.lblName:MoveRightOf( self.imgAvatar, 8 )

	local COLUMN_SIZE = 50

	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 2, 0 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 3, 0 )

	if ( self.Open || self.Size ~= self.TargetSize ) then

		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 4, 36)--self.imgAvatar:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )

	else

		self.infoCard:SetVisible( false )

	end



end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )
	if not IsValid(self.Player) then return false end
	if not IsValid( row.Player) then return true  end
	return self.Player:Team() < row.Player:Team()

end


vgui.Register( "ScorePlayerRow", PANEL, "Button" )
