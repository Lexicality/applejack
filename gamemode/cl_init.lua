--[[
Name: "cl_init.lua".
	~ Applejack ~
--]]

include("sh_init.lua");
include("scoreboard/scoreboard.lua");

-- Set some information for the gamemode.
GM.topTextGradient = {};
GM.variableQueue = {};
GM.ammoCount = {};
--Take some shit out of _G for speed
local	ents, player, pairs, ipairs, draw, math, string, CurTime, ErrorNoHalt, Color, hook, ScrW, ScrH, tonumber, util =
		ents, player, pairs, ipairs, draw, math, string, CurTime, ErrorNoHalt, Color, hook, ScrW, ScrH, tonumber, util
-- Define a fuckton of colours for efficient GC
--Solid Colours
color_green =			Color(050, 255, 050)
color_red =				Color(255, 050, 050)
color_orange =			Color(255, 125, 000)
color_brightgreen =		Color(125, 255, 050)
color_purpleblue =		Color(125, 050, 255)
color_purple = 			Color(150, 075, 200)
color_lightblue =		Color(075, 150, 255)
color_pink =			Color(255, 075, 150)
color_darkgray =		Color(025, 025, 025)
color_lightgray =		Color(150, 150, 150)
color_yellow =			Color(250, 230, 070)
color_blue =			Color(015, 045, 230)
--Alpha'd
color_red_alpha =		Color(255, 050, 050, 200)
color_orange_alpha =	Color(240, 190, 060, 200)
color_lightblue_alpha =	Color(100, 100, 255, 200)
color_darkgray_alpha =	Color(025, 025, 025, 150)
color_black_alpha =		Color(000, 000, 000, 200)
lpl = 					NULL
local startupmenu = 	CreateClientConVar("mshine_startupmenu", "1", true)

-- Detect when the local player is created 
function GM:OnEntityCreated(entity)
	if (lpl == NULL and entity == LocalPlayer()) then
		lpl = entity;
		gamemode.Call("LocalPlayerCreated", lpl);
	end
	
	-- Call the base class function.
	return self.BaseClass:OnEntityCreated(entity);
end
function GM:LocalPlayerCreated(ply) end

function GM:Initialize()
	ErrorNoHalt(os.date().." - Finished connecting\n")
	GM = self;
	-- Call the base class function.
	return self.BaseClass:Initialize()
end

function GM:ForceDermaSkin()
	return;
end

-- Override the weapon pickup function.
function GM:HUDWeaponPickedUp() end

-- Override the item pickup function.
function GM:HUDItemPickedUp() end

-- Override the ammo pickup function.
function GM:HUDAmmoPickedUp() end

-- Called when all of the map entities have been initialized.
function GM:InitPostEntity()
	timer.Simple(0,hook.Call,"LoadData",self); -- Tell plugins to load their datas a frame after this.
	self.Inited = true;
	-- Call the base class function.
	return self.BaseClass:InitPostEntity()
end

-- Called when a player presses a bind.
function GM:PlayerBindPress(player, bind, press)
	if ( !self.playerInitialized and string.find(bind, "+jump") ) then
		RunConsoleCommand("retry");
	end
	-- Call the base class function.
	return self.BaseClass:PlayerBindPress(player, bind, press);
end

-- Check if the local player is using the camera.
function GM:IsUsingCamera()
	local wpn = lpl:GetActiveWeapon();
	return IsValid(wpn) and wpn:GetClass() == "gmod_camera";
end

-- Get the bouncing position of the screen's center.
function GM:GetScreenCenterBounce(bounce)
	return ScrW() / 2, (ScrH() / 2) + 32 + ( math.sin( CurTime() ) * (bounce or 8) );
end

-- Give the player a first-person view of their corpse
function GM:CalcView( pl, origin, angles, fov )
	-- Get their ragdoll
	local ragdoll = pl:GetRagdollEntity();
	-- Check if it's valid
	if (not IsValid(ragdoll)) then
		return self.BaseClass:CalcView(pl,origin,angles,fov);
	end
	--find the eyes
	local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
	-- setup our view
	if (not eyes) then
		return self.BaseClass:CalcView(pl,origin,angles,fov);
	end
	-- TODO: See if this does anything
	return self.BaseClass:CalcView(pl, eyes.Pos, eyes.Ang, 90);
	--[[
	local view = {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = 90, 
	};
	return view;
	--]]
end
--]]

-- Called when screen space effects should be rendered.
function GM:RenderScreenspaceEffects()
	local modify = {};
	local color = 0.8;
	local addr = 0
	
	-- Check if the player is low on health or stunned.
	if lpl._Stunned then
		color = 0.4
		DrawMotionBlur(0.1,1,0)
	elseif (lpl:Health() < 50 and !lpl._HideHealthEffects) then
		if ( lpl:Alive() ) then
			color = math.Clamp(color - ( ( 50 - lpl:Health() ) * 0.025 ), 0, color);
		else
			color = 1.13;
			addr = 1
		end
		-- Draw the motion blur.
		DrawMotionBlur(math.Clamp(1 - ( ( 50 - lpl:Health() ) * 0.025 ), 0.1, 1), 1, 0);
	end
	
	-- Set some color modify settings.
	modify["$pp_colour_addr"] = addr;
	modify["$pp_colour_addg"] = 0;
	modify["$pp_colour_addb"] = 0;
	modify["$pp_colour_brightness"] = 0;
	modify["$pp_colour_contrast"] = 1;
	modify["$pp_colour_colour"] = color;
	modify["$pp_colour_mulr"] = 0;
	modify["$pp_colour_mulg"] = 0;
	modify["$pp_colour_mulb"] = 0;
	local slp = lpl._GoToSleepTime;
	if (slp and slp > 0) then
		local t = slp - CurTime();
		if (t > 0) then
			modify["$pp_colour_contrast"] = t / GM.Config["Sleep Waiting Time"];
		else
			modify["$pp_colour_contrast"] = 0;			
		end
	end
	if lpl._Sleeping then
		modify["$pp_colour_contrast"] = 0
	end
	
	-- Draw the modified color.
	DrawColorModify(modify);
end

-- Called when the scoreboard should be drawn.
function GM:HUDDrawScoreBoard() -- TODO: Find a better hook for this?
	self.BaseClass:HUDDrawScoreBoard(player);
	if (self.playerInitialized) then
		-- Remove this hook
		self.HUDDrawScoreBoard = self.BaseClass.HUDDrawScoreBoard;
		return;
	end
	
	-- Blank out the screen while players load.
	
	draw.RoundedBox( 2, 0, 0, ScrW(), ScrH(), color_black );
	
	-- Set the font of the text to Chat Font.
	surface.SetFont("ChatFont");
	
	-- Get the size of the loading text.
	local width, height = surface.GetTextSize("Loading!");
	
	-- Get the x and y position.
	local x, y = self:GetScreenCenterBounce();
	
	-- Draw a rounded box for the loading text to go on.
	draw.RoundedBox( 2, (ScrW() / 2) - (width / 2) - 8, (ScrH() / 2) - 8, width + 16, 30, color_darkgray );
	
	-- Draw the loading text in the middle of the screen.
	draw.DrawText("Loading!", "ChatFont", ScrW() / 2, ScrH() / 2, color_white, 1, 1);
	
	-- Let them know how to rejoin if they are stuck.
	draw.DrawText("Press 'Jump' to rejoin if you are stuck on this screen!", "ChatFont", ScrW() / 2, ScrH() / 2 + 32, Color(255, 50, 25, 255), 1, 1);
end

-- Draw Information.
function GM:DrawInformation(text, font, x, y, color, alpha, left, callback, shadow)
	surface.SetFont(font);
	
	-- Get the width and height of the text.
	local width, height = surface.GetTextSize(text);
	if alpha then color.a = alpha end
	-- Check if we shouldn't left align it, if we have a callback, and if we should draw a shadow.
	if (!left) then x = x - (width / 2); end
	if (callback) then x, y = callback(x, y, width, height); end
	if (shadow) then draw.DrawText(text, font, x + 1, y + 1, Color(0, 0, 0, color.a)); end
	
	-- Draw the text on the player.
	draw.DrawText(text, font, x, y, color);
	
	-- Return the new y position.
	return y + height + 8;
end

-- Stop players bypassing my post proccesses with theirs
function GM:PostProcessPermitted() return LocalPlayer():IsAdmin() end

--[[ Shit but required for now (ick) ]]--

local function iHasInitializedyay()
	if ValidEntity(LocalPlayer()) then
		GAMEMODE.playerInitialized = true
		if startupmenu:GetBool() then
			cider.menu.toggle()
		end
	else
		timer.Simple(0.2,iHasInitializedyay)
	end
end
-- Hook into when the player has initialized.
usermessage.Hook("cider.player.initialized", iHasInitializedyay);
--[[		umsg.Start("cider_ModelChoices")
		umsg.Short(#player._ModelChoices)
		for name,gender in pairs(player._ModelChoices) do
			umsg.String(name)
			umsg.Short(#gender)
			for team,choice in ipairs(gender) do
				umsg.Short(team)
				umsg.Short(choice)
			end
		end
		umsg.End()]]
	local errors = 0
	local maxerrors = GM.Config["Model Choices Timeout"]
	local function CheckForInitalised(tab)
		
		if errors >= maxerrors then
			ErrorNoHalt"Something is very wrong - reconnecting!"
			RunConsoleCommand("retry");
		elseif errors == maxerrors/2 then
			ErrorNoHalt("Critical error! You have ".. maxerrors/2 .." seconds before your client reconnects!\n")
			ErrorNoHalt("LocalPlayer() is not a valid entity after "..errors.." seconds of gameplay!")
			ErrorNoHalt("LocalPlayer(): "..tostring(LocalPlayer()).."\n")
			ErrorNoHalt("---------------------------\n")
		end
		if !ValidEntity(LocalPlayer()) then
			errors = errors + 1
		--	ErrorNoHalt("LocalPlayer is invalid! ("..errors.."/"..maxerrors..")\n")
			return timer.Simple(1,CheckForInitalised,tab)
		end
		--if errors > 0 then ErrorNoHalt"Nevermind it works now...\n" end
		LocalPlayer()._ModelChoices = tab
	end	
usermessage.Hook("cider_ModelChoices",function(msg)
	local tab = {}
	local length = msg:ReadShort() or 0
	for i=1, length do
		local gender = msg:ReadString() or ""
		tab[gender] = {}
		local leng = msg:ReadShort()
		for j = 1, leng do
			tab[gender][msg:ReadShort() or 0] = msg:ReadShort() or 0
		end
	end
	CheckForInitalised(tab)
end)