--[[
	~ HUD Library ~
	~ Applejack ~
--]]

--require("CSVars");

-- Setup the basics
local font = "mshine_hudtxt"
surface.CreateFont("Tahoma", 12, 400, true, false, font);
surface.SetFont(font);
local sidewidth,textheight = surface.GetTextSize("100%");
local scrw, scrh = ScrW(), ScrH();
local function unpackcolour(c)
	if (not c) then error("what",2) end
	if (type(c) == "string") then
		error("what the christ '" .. c .. "'.", 2);
	end
	return c.r, c.g, c.b, c.a;
end
local ctime = CurTime()


-------------------------------------
-- Bottom Bars (Health / ammo etc) --
-------------------------------------
local drawbars
do
local bars = {};
local barwidth = 108;
local barheight = textheight + 8;
local border = 4;
local border2 = border * 2;
local bary = scrh - barheight - 5; -- Where the current bar should be drawing.
local texty = (barheight - 10 - textheight) / 2 + 1;
local length, x, y, width, height;
local function drawbar(bar)
	length = bar:length();
	if (length == -1) then -- This allows bars to hide themselves
		return;
	end
	x, y = 0, bary;
	width, height = barwidth, barheight;
	surface.DrawRect(x, y, width + sidewidth, height);
	x = sidewidth + border;
	y = y + border;
	height = height - border2;
	width = width - border2;
	if (length > 0) then
		if (not bar.colour) then
			Error("wtf broken bar", bar.text);
		end
		surface.SetDrawColor(unpackcolour(bar.colour));
		surface.DrawRect(x, y, length, height);
	end
	x = x + (width - bar.textwidth) / 2;
	surface.SetTextPos(x, y + texty);
	surface.DrawText(bar.text);
	bary = bary - barheight - 5
end

function drawbars()
	bary = scrh - barheight - 5;
	surface.SetTextColor(255,255,255,255);
	for _, bar in pairs(bars) do
		surface.SetFont(font);
		surface.SetDrawColor(0,0,0,150);
		drawbar(bar);
	end
end

---
-- Add a bar to the bottom left of the HUD
-- If you wish to modify the text on the bar, do so in the length function, changing self.text and self.textwidth as appropriate.
-- The font the bar is drawn in is already set, so surface.GetTextSize will work.
-- @param text The text to display
-- @param colour The colour of the bar
-- @param lengthfunc A function to be called every time the length should be calculated. Gets passed the bar as the first argument.
function GM:AddHUDBar(text, colour, lengthfunc)
	surface.SetFont(font);
	bars[#bars+1] = {
		colour = colour,
		text = text,
		length = lengthfunc,
		textwidth = surface.GetTextSize(text);
	}
end
-- Add our default bars
local h1,h2
GM:AddHUDBar("Health: 100", Color(255, 0, 0), function(self)
	h1 = lpl:Health();
	self.text = "Health: " .. h1;
	h2 = math.min(h1, 100);
	return h1 == 100 and -1 or h2;
end);
local ammos = {}
local wep, class, clip, max, txt;
GM:AddHUDBar("Ammoz: nil", Color(0, 0, 255), function(self)
	wep = lpl:GetActiveWeapon();
	if (not IsValid(wep)) then
		return -1;
	end
	class = wep:GetClass();
	clip = wep:Clip1();
	max = ammos[class];
	if (not max or clip > max) then
		ammos[class] = clip;
		max = clip;
	end
	if (max < 1) then
		return -1;
	end
	txt = clip .. "/" .. max .. " (" .. lpl:GetAmmoCount(wep:GetPrimaryAmmoType()) .. ")";
	self.text = txt;
	self.textwidth = surface.GetTextSize(txt);
	return (clip / max) * 100;
end);
local num
do -- Job Timer
local ends, length;
--CSVars.Hook(
GM:AddHUDBar("Job Timer: 00:00", color_orange, function(bar)
	num = (lpl._JobTimeExpire or 0) - ctime
	if (num <= 0) then
		return -1;
	end
	bar.text = "Job Timer: " .. string.ToMinutesSeconds(math.floor(num));
	return (num / (lpl._JobTimeLimit or 0)) * 100;
end);
end
GM:AddHUDBar("Arrest Time: 0:00", color_red, function(bar)
	num = (lpl._UnarrestTime or 0) - ctime
	if (num <= 0) then
		return -1
	end
	bar.text = "Arrest Time: " .. string.ToMinutesSeconds(num)
	return (num / GM.Config["Arrest Time"]) * 100;
end);

end

------------------------------------------
-- Top Boxes (Name / gender / clan etc) --
------------------------------------------
local drawboxes
do
local dyboxes, statboxes = {}, {};
local boxheight = 20;
-- Our boxes are 50 chars wide.
local boxwidth = surface.GetTextSize("12345678901234567890123456789012345678901234567890");
local by = 10;
local iconx = (sidewidth - 16) / 2;
local icony = (boxheight - 16) / 2;
local texty = (boxheight - textheight) / 2;
local text, icon;
local function paintbox(box, text) -- Does the basic shit for the box
	surface.SetDrawColor(0, 0, 0, 150);
	surface.DrawRect(0, by, boxwidth + sidewidth, boxheight);
	icon = box.icon;
	if (icon) then
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetTexture(icon);
		surface.DrawTexturedRect(iconx, by + icony, 16, 16);
	end
	surface.DrawText(text);
end
local function dynamicbox(box) -- Boxes that can change their contents (countdowns etc)
	text = box:text();
	if (text == -1) then return end
	surface.SetTextPos(sidewidth + (boxwidth - surface.GetTextSize(text)) / 2, by + texty);
	paintbox(box, text);
	by = by + boxheight + 2;
end
local function staticbox(box) -- Boxes with static text (You are wearing kevlar etc)
	if (box.todraw and not box:todraw()) then return end -- Allow even static boxes to hide themselves.
	surface.SetTextPos(box.textx, by + texty)
	paintbox(box, box.text);
	by = by + boxheight + 2;
end

local w;
function drawboxes()
	by = 10;
    w = lpl:GetActiveWeapon();
    if (IsValid(w) and w:GetClass() == "gmod_tool") then
        by = by + w.ToolNameHeight + w.InfoBoxHeight - 8;
    elseif (GetConVarNumber("developer") > 0) then
		by = by + 82;--(boxheight + 3) * 3 + 3;
	end
	surface.SetFont(font);
	surface.SetTextColor(255, 255, 255, 255);
	for _, box in pairs(statboxes) do
		staticbox(box);
	end
	for _, box in pairs(dyboxes) do
		dynamicbox(box);
	end
end

---
-- Add a static info box whose contents do not change
-- @param text The text to display in the box
-- @param icon (optional) An icon to display on the left of the box
-- @param candraw (optional) A function to determine whether or not to display the box right now. Passed the box.
function GM:AddStaticHUDBox(text, icon, candraw)
	surface.SetFont(font);
	statboxes[#statboxes + 1] = {
		text = text,
		icon = icon and surface.GetTextureID(icon),
		todraw = candraw,
		textx = sidewidth + (boxwidth - surface.GetTextSize(text)) / 2,
	}
end

---
-- Add a dynamic info box whose contents can change between frames.
-- @param textfunc A function that returns the text to draw in the box
-- @param icon (optional) An icon to display on the left of the box
function GM:AddDynamicHUDBox(textfunc, icon)
	dyboxes[#dyboxes+1] = {
		text = textfunc,
		icon = icon and surface.GetTextureID(icon),
	}
end

local text

-- Name
GM:AddDynamicHUDBox(function(self)
	return "Name: " .. lpl:Name():sub(1,43);
end,"gui/silkicons/user");

-- Gender
do
local mi,fi = surface.GetTextureID("gui/silkicons/male"), surface.GetTextureID("gui/silkicons/female");
GM:AddDynamicHUDBox(function(box)
	text = lpl._Gender or "???"
	if (text ~= box.gender) then
		if (text == "Female") then
			box.icon = fi;
		else
			box.icon = mi;
		end
		box.gender = text;
	end
	return "Gender: " .. text;
end);
end

-- Clan
GM:AddDynamicHUDBox(function(box)
	text = lpl:GetNWString("Clan");
	if (text == "") then
		return -1;
	end
	return "Clan: " .. text;
end,"gui/silkicons/group");

-- Salary
GM:AddDynamicHUDBox(function(box)
	return "Salary: $" .. (lpl._Salary or 0);
end, "gui/silkicons/money"); -- Previously money_add

-- Cash
GM:AddDynamicHUDBox(function(box)
	return "Money: $" .. (lpl._Money or 0);
end, "gui/silkicons/coins"); -- previously money

-- Job
GM:AddDynamicHUDBox(function(box)
	return "Job: " .. lpl:GetNWString("Job");
end, "gui/silkicons/wrench");

-- Details
GM:AddDynamicHUDBox(function(box)
	text = lpl:GetNWString("Details");
	if (text == "") then
		return -1;
	end
	return "Details: " .. text;
end, "gui/silkicons/vcard");

-- Warrant
GM:AddDynamicHUDBox(function(box)
	text = lpl:GetNWString("Warrant")
	if (text == "") then
		return -1;
	end
	return "You have a " .. text .. " warrant!";
end,"gui/silkicons/page_white_text")

-- Kevlar
GM:AddStaticHUDBox("You are wearing Kevlar", "gui/silkicons/shield", function(box)
	return lpl._ScaleDamage == 0.5;
end);

-- Website
GM:AddStaticHUDBox(GM.Config["Website URL"], "gui/silkicons/link");
-- Arrested
GM:AddStaticHUDBox("You have been arrested.", "gui/silkicons/lock", function(box)
	return lpl:Arrested();
end);

-- Tied
GM:AddStaticHUDBox("You have been tied up.", "gui/silkicons/link", function(box)
	return lpl:Tied();
end);

end

------------------------------------------
-- Hints (Money alerts / notifications) --
------------------------------------------
local drawhints;
do
local hints = {};
local hintfont = "TabLarge";
surface.SetFont(hintfont);
local _, textheight = surface.GetTextSize("M");
local hintheight = textheight + 10;
local hinty = scrw - hintheight - 5;
local cnum = 1; -- Because hints get deleted
local hintlength = 10; -- Hints stay up for 10 seconds by default
local texty = 5;
local textx = 7;
local hintborder = 6;
local hintstartpos = math.floor(scrh / 4);
local hintendpos = math.floor(scrh * 2 / 3);

local width, height, x, y, calc, dir, lastdir;
local IN, OUT, SHAKE_IT_ALL_ABOUT = 1, 2, 3;
local function calcpos(x, y, dir, width)
	if (dir == IN) then
		x = x - 10;
		calc = scrw - width;
		if (x < calc) then
			x = calc;
			dir = SHAKE_IT_ALL_ABOUT;
		end
	elseif (dir == OUT) then
		x = x + 3;
		if (x >= scrw) then
			dir = false;
		end
	end
	if (dir and y ~= hinty) then
		y = y + (y > hinty and -1 or 1);
	end
	return x, y, dir;
end
local function painttimed(hint, time)
	width, height = hint.width + hintborder + textx, hintheight;
	x, y = hint.x, hint.y;
	if (not hint.timer) then
		dir = IN;
	elseif (hint.timer < time) then
		dir = OUT;
	else
		hint.live = hint.timer ~= time 
		dir = SHAKE_IT_ALL_ABOUT;
	end
	lastdir = dir;
	x, y, dir = calcpos(x, y, dir, width);
	if (lastdir ~= dir) then
		if (lastdir == IN) then
			hint.timer = time + hint.length;
			hint.live = true;
		elseif (lastdir == OUT) then
			return false;
		end
	end
	hint.x = x;
	hint.y = y;
	if (dir == SHAKE_IT_ALL_ABOUT) then
		-- Not strictly necessary, but looks ok
		calc = ((hint.timer - time) / hint.length) * hintheight;
		surface.SetDrawColor(200, 200, 200, 255);
		surface.DrawRect(scrw - hintborder, y + hintheight - calc, hintborder, calc);
	end
	surface.SetDrawColor(0, 0, 0, 220);
	surface.DrawRect(x, y, width, height);
	if (hint.live) then
		if (hint.sound) then
			surface.PlaySound(hint.sound);
			hint.sound = nil;
		end
		if (hint.colour) then
			hint.flash = hint.flash or (time + 0.5);
			calc = hint.flash - time;
			if (calc <= 0.25) then
				surface.SetDrawColor(unpackcolour(hint.colour));
				surface.DrawRect(x, y, width, height);
				if (calc <= 0) then
					hint.flash = time + 0.5;
					hint.flashes = hint.flashes + 1;
					if (hint.flashes == 2) then
						hint.colour = nil;
					end
				end
			end
		end
	end 
	surface.SetTextPos(x + textx, y + texty);
	surface.DrawText(hint.text);
end
local function paintperm(hint, time)
	width, height = hint.width + hintborder + textx, hintheight;
	x, y = hint.x, hint.y;
	if (not hint.gotin) then
		dir = IN;
	elseif (hint.goinout) then
		dir = OUT;
	else
		hint.goinout = not hint:isalive()
		dir = SHAKE_IT_ALL_ABOUT;
	end
	lastdir = dir;
	x, y, dir = calcpos(x, y, dir, width);
	if (lastdir ~= dir) then
		if (lastdir == IN) then
			hint.gotin = true;
		elseif (lastdir == OUT) then
			return false;
		end
	end
	hint.x = x;
	hint.y = y;
	surface.SetDrawColor(0, 0, 0, 220);
	surface.DrawRect(x, y, width, height);
	if (hint.gotin and not hint.goinout) then
		if (hint.sound) then
			surface.PlaySound(hint.sound);
			hint.sound = nil;
		end
		if (hint.colour) then
			-- Change to a steady colour after 5 flashes.
			if (hint.flashes > 5) then
				calc = 0.1;
			else
				hint.flash = hint.flash or (time + 0.5);
				calc = hint.flash - time;
			end
			if (calc <= 0.25) then
				surface.SetDrawColor(unpackcolour(hint.colour));
				surface.DrawRect(x, y, width, height);
				if (calc <= 0) then
					hint.flash = time + 0.5;
					hint.flashes = hint.flashes + 1;
				end
			end
		end
	end 
	surface.SetTextPos(x + textx, y + texty);
	surface.DrawText(hint.text);
end

function drawhints()
	surface.SetDrawColor(0, 0, 0, 150);
	surface.DrawRect(scrw - hintborder, 0, hintborder, scrh);
	hinty = hintendpos;
	local time = RealTime()
	surface.SetFont(hintfont);
	surface.SetTextColor(255, 255, 255, 255);
	local pfunc;
	for _, hint in ipairs(hints) do if (hint) then
		pfunc = hint.isalive and paintperm or painttimed;
		if (pfunc(hint, time) == false) then
			hints[_] = false;
		else
			hinty = hint.y - hintheight - 5;
			if (hinty < 0) then break; end
		end
	end end
end
-- Un-redundancy
local function dohint(text, colour, sound)
	surface.SetFont(hintfont);
	local hint = {
		colour = colour;
		text = text;
		sound = sound;
		width = surface.GetTextSize(text) + hintborder;
		num = cnum;
		x = scrw;
		y = hinty;
		flashes = 0;
	}
	hints[cnum] = hint;
	cnum = cnum + 1;
	return hint;
end

---
-- Adds a hint to the right hand hint bar
-- @param text The hint text
-- @param length How long the hint should persist before shrinking away
-- @param color The colour for the hint to flash when it enters fully
-- @param sound The sound to make as the colour flashes. 
function GM:AddNotification(text, length, color, sound)
	dohint(text, color, sound).length = length or hintlength;
end

---
-- Adds a hint to the right hand hint bar that does not fade with time
-- @param text The hint text
-- @param keepfunc The function that is called every draw to check if the hint should remain alive
-- @param color The colour for the hint to flash continuously
-- @param sound The sound to make once when it enters fully
function GM:AddPermaNotification(text, keepfunc, color, sound)
	dohint(text, color, sound).isalive = keepfunc;
end

local red = Color(255, 0, 0);
function GM:LimitHit( name )
	Msg("You have hit the ".. name .." limit!\n")
	self:AddNotification("#SBoxLimit_"..name, 6, red, "buttons/button10.wav" );
end

function GM:OnUndo( name, strCustomString )
	Msg( name .." undone\n" )
	if ( not strCustomString ) then
		strCustomString = "#Undone_"..name
	end
	self:AddNotification( strCustomString, 2, nil, "buttons/button15.wav" )
end

function GM:OnCleanup( name )

	Msg( name .." cleaned\n" )
	self:AddNotification( "#Cleaned_"..name, 5, nil, "buttons/button15.wav" )

end

function GM:UnfrozeObjects( num )

	Msg( "Unfroze "..num.." Objects\n" )
	self:AddNotification( "Unfroze "..num.." Objects", 3, nil, "npc/roller/mine/rmine_chirp_answer1.wav" )

end

function GM:AddNotify(words, _, time)
	self:AddNotification(words, time)
end

-- Money Notifications
usermessage.Hook("MoneyAlert", function(msg)
	amount = msg:ReadLong();
	local text,colour;
	if (amount < 0) then
		text = "";
	else
		text = "+"
	end
	GM:AddNotification(text .. "$" .. amount, 2);
end);

-- Normal Notifications
usermessage.Hook("Notification", function(msg)
	local message = msg:ReadString();
	local class = msg:ReadChar();
	if message == "" then return end
	-- The sound of the notification.
	local sound = "ambient/water/drip2.wav"; -- 'drip' generic notification
	local color;--= color_white;
	-- Check the class of the message.
	if (class == 1) then
		sound = "buttons/button10.wav"; -- 'failure' buzzer
		color = color_red;
	elseif (class == 2) then
		sound = "buttons/button17.wav"; -- 'bip' notification
		color = color_blue;
	elseif (class == 3) then
		sound = "buttons/bell1.wav"; 	-- 'bing' hint notification
		color = color_green
	elseif (class == 4) then
		sound = "buttons/button15.wav"; -- 'tic' undo notification
		color = color_yellow
	end
	GM:AddNotification(message, 10, color, sound); -- TODO: work out colours!
	print(message);
end);
end 

--[[ Center Bar ]]--
-- TODO: The centerbar needs to be in a stack
local drawcenterbar;
do
local font = "HudHintTextLarge";
surface.SetFont(font);
local _,textheight = surface.GetTextSize("0");
local barheight = textheight*1.5;
local pad = 4;
local barwidth = math.floor(scrw / 4);
local backgroundheight = barheight + (pad+4)*2
local backgroundy = math.floor(scrh/2-backgroundheight/2);
local barx = (scrw-barwidth) / 2;
local bary = (backgroundy + (pad+4)); 
local barpercent = 1;
-- paddings
local toppady = bary-pad;
local bottompady = bary+barheight;
local leftpadx = barx - pad;
local rightpadx = barx + barwidth;
local sidepady = bary - pad;
local sidepadheight = barheight+pad*2;

local textx, texty, tw;
texty = bary + textheight * 0.25
local updown;
function calculateBar(percent)
    percent = percent / 100
    return (updown and (barx + barwidth*(1-percent)) or barx), barwidth*percent;
end
local stack = {};
local x, width;
local data;
local perc, dir, txt;
local size, cback;
function drawcenterbar()
	size = #stack;
	if (size == 0) then return; end
	-- Get datas
	data = stack[size]
    perc, dir = data.func(barpercent,updown);
    if (not perc) then
		-- If this bar dies, pop the stack
		table.remove(stack);
		-- Do the next bar
		return drawcenterbar();		
	end
    surface.SetDrawColor(0, 0, 0, 200);
    surface.DrawRect(0, backgroundy, scrw, backgroundheight);  
    surface.SetDrawColor(0, 0, 0, 255); 
    surface.DrawRect(barx, toppady, barwidth, pad);  
    surface.DrawRect(barx, bottompady, barwidth, pad);
    surface.DrawRect(leftpadx, sidepady, pad, sidepadheight);
    surface.DrawRect(rightpadx, sidepady, pad, sidepadheight);
    surface.SetDrawColor(0, 0, 0, 150);
    surface.DrawRect(barx, bary, barwidth, barheight);
    barpercent = perc;
    updown = dir;
    x, width = calculateBar(barpercent);
    surface.SetDrawColor(unpackcolour(data.colour));
    surface.DrawRect(x, bary, width, barheight);
    surface.SetFont(font);
    surface.SetTextColor(255, 255, 255, 255);
    surface.SetTextPos(data.textx, texty);
    surface.DrawText(data.text);
end
local textcenter = barx + (barwidth / 2);
function GM:SetCenterBar(text, color, callback)
	local data = {}
	data.text = text;
	data.colour = color;
	data.func = callback;
    surface.SetFont(font);
    tw = surface.GetTextSize(text);
    data.textx = textcenter - tw / 2;
	table.insert(stack, data);
end
hook.Add("LibrariesLoaded", "CSVars shit for teh hud", function()
	
	do -- Sleepering
		local endtime, length, left;
		local function sleepfunc()
			endtime = lpl._GoToSleepTime;
			if (not (length and endtime and endtime > 0)) then return false; end
			left = endtime - ctime;
			if (left < 0) then
				return false;
			end
			return (left/length) * 100, false;
		end
		local sleepcolor = Color(34,66,205);
		CSVars.Hook("_GoToSleepTime","CentreBar",function(ends)
			if (ends == 0) then
				return;
			end
			length = ends - CurTime();
			GM:SetCenterBar("Going To Sleep . . .", sleepcolor, sleepfunc);
		end);
	end
	
	do -- Bondage
		local tends, bends, uends, dends;
		do -- Tying
			local length, left = GM.Config["Tying Timeout"];
			local function callback()
				if (not tends) then return false; end
				left = tends - ctime;
				if (left < 0) then
					return false;
				end
				return (left/length) * 100, false;
			end
			local barcolor = Color(221,133,38);
			local function umsg(msg)
				tends = CurTime() + length;
				GM:SetCenterBar("Tying knots . . .", barcolor, callback);
			end
			usermessage.Hook("MS DoTie", umsg);
		end
		
		do -- Being Tied
			local length, left = GM.Config["Tying Timeout"];
			local function callback()
				if (not bends) then return false; end
				left = bends - ctime;
				if (left < 0) then
					return false;
				end
				return (left/length) * 100, false;
			end
			local barcolor = Color(221,133,38);
			local function umsg(msg)
				bends = CurTime() + length;
				GM:SetCenterBar("You are being tied up!", barcolor, callback);
			end
			usermessage.Hook("MS BeTie", umsg);
		end
		
		do -- Untying
			local length, left = GM.Config['UnTying Timeout'];
			local function callback()
				if (not (length and uends)) then return false; end
				left = uends - ctime;
				if (left < 0) then
					return false;
				end
				return 100 - (left/length) * 100, true; -- Display backwards!
			end
			local barcolor = Color(150,210,20);
			local function umsg(msg)
				uends = CurTime() + length;
				GM:SetCenterBar("Attempting to untie knots . . .", barcolor, callback);
			end
			usermessage.Hook("MS DoUnTie", umsg);
		end
		
		do -- Being Untied
			local length, left = GM.Config['UnTying Timeout'];
			local function callback()
				if (not (length and dends)) then return false; end
				left = dends - ctime;
				if (left < 0) then
					return false;
				end
				return 100 - (left/length) * 100, true; -- Display backwards!
			end
			local barcolor = Color(150,210,20);
			local function umsg(msg)
				dends = CurTime() + length;
				GM:SetCenterBar("You are being untied!", barcolor, callback);
			end
			usermessage.Hook("MS BeUnTie", umsg);
		end
		usermessage.Hook("MS CancelTie", function()
			tends, bends, uends, dends = nil, nil, nil, nil;
		end);
	end

	do -- Stuck! (Bit of a cheat but hey)
		local active
		local function callback()
			return active and 100;
		end
		local barcolor = Color(255,0,0);
		CSVars.Hook("_StuckInWorld", "Centrebar", function(stuck)
			active = stuck;
			if (active) then
				GM:SetCenterBar("Jump to respawn.", barcolor, callback);
			end
		end);
	end
	
	do -- Respawning 
		local ends, length, left;
		local function callback()
			if (not (length and ends)) then return false; end
			left = ends - ctime;
			if (left < 0) then
				return false;
			end
			return 100 - ((left/length) * 100);
		end
		local barcolor = Color(150,210,20);
		local function timr()
			GM:SetCenterBar("Respawning . . .", barcolor, callback);
		end
		
		local function umsg(msg)
			length = msg:ReadShort();
			ends = CurTime() + length;
			timer.Simple(0.01, timr);
		end
		usermessage.Hook("MS Respawn Time", umsg);
		usermessage.Hook("PlayerSpawned", function()
			ends = false;
		end);
	end
	
	do -- Reganing Consiousness
		-- TODO: Make the screen de-fade with this like it fades with sleep.
		local endtime, length, left;
		local function callback()
			endtime = lpl._WakeUpTime;
			if (not (length and endtime)) then return false; end
			left = endtime - ctime;
			if (left < 0) then
				return false;
			end
			return (left/length) * 100;
		end
		local barcolor = Color(150,210,20);
		CSVars.Hook("_WakeUpTime","CentreBar",function(ends)
			length = ends - CurTime();
			GM:SetCenterBar("Waking Up . . .", barcolor, callback);
		end);
	end
	
	do -- /fallover recovery
		local ends, length, left;
		local function callback()
			if (not (length and ends)) then return false; end
			left = ends - ctime;
			if (left < 0 or not lpl:KnockedOut()) then
				return false;
			end
			return 100 - ((left/length) * 100);
		end
		local barcolor = Color(150,210,20);
		local function timr()
			GM:SetCenterBar("Recovering . . .", barcolor, callback);
		end			
		local function umsg(msg)
			length = msg:ReadShort();
			ends = CurTime() + length;
			timer.Simple(0.01, timr);
		end
		usermessage.Hook("MS Recovery Time", umsg);
	end
		
	
	-- 
	-- TODO: go to sleep -> says 'wake up' -> hit jump -> says 'reganing consiousness' -> says 'get up'
	--
	
	do -- Wakup Announcement
		local function blaaa()
			return lpl:KnockedOut() and 0 or false;
		end
		local blaa = Color(0,0,0);
		local function wakethefuckup(msg)
			if (msg:ReadBool()) then
				GM:SetCenterBar("Press 'Jump' to wake up", blaa, blaaa);
			else
				GM:SetCenterBar("Press 'Jump' to get up", blaa, blaaa);
			end
		end
		usermessage.Hook("MS Wakeup Call",wakethefuckup);
	end
	
	do -- /holster and equipping
		local ends, length, left;
		local function callback()
			if (not (length and ends)) then return false; end
			left = ends - ctime;
			if (left < 0) then
				return false;
			end
			return 100 - ((left/length) * 100);
		end
		local barcolor = Color(54, 206, 197);
		local function umsg(msg)
			length = msg:ReadShort();
			ends = CurTime() + length;
			local mode = msg:ReadBool();
			local str = "";
			if (mode) then
				str = "Equipp";
			else
				str = "Holster";
			end
			GM:SetCenterBar(str .. "ing . . .", barcolor, callback);
		end
		usermessage.Hook("MS Equippr", umsg);
		usermessage.Hook("MS Equippr FAIL", function() ends = false; end);
	end		
end);
end


--[[ SBox Functions ]]--
function GM:HUDPaint()
	ctime = CurTime();
	self:HUDPaintESP();
	surface.SetDrawColor(0,0,0,150);
    
    local num = 0;
    local w = lpl:GetActiveWeapon();
    if (IsValid(w) and w:GetClass() == "gmod_tool") then
        num = 0;--w.ToolNameHeight + w.InfoBoxHeight; -- I figure do the whole thing, it looks pretty pimp.
    elseif (GetConVarNumber("developer") > 0) then
        num = 82;
    end

	surface.DrawRect(0,num,sidewidth,scrh - num);
	if (gamemode.Call("HUDShouldDraw", "MSBars")) then
		drawbars();
	end if (gamemode.Call("HUDShouldDraw", "MSInfoBoxes")) then
		drawboxes();
	end if (gamemode.Call("HUDShouldDraw", "MSHints")) then
		drawhints();
	end if (gamemode.Call("HUDShouldDraw", "MSCenterBar")) then
		drawcenterbar();
	end
	--self.BaseClass:HUDPaint()
	
	-- Legacy centerprints
	if ( not self:IsUsingCamera() ) then
		-- Set the position of the chat box.
		cider.chatBox.position = {x = 30, y = scrh - 160};
		
		-- Call the base class function.
		self.BaseClass:HUDPaint();
	end
end

function GM:HUDShouldDraw(name)
	if (not self.playerInitialized) then
		if (name ~= "CHudGMod") then
			return false;
		end
	elseif (name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower"
		or  name == "CHudAmmo"   or name == "CHudSecondaryAmmo") then
			return false;
		end
	
	-- Call the base class function.
	return self.BaseClass:HUDShouldDraw(name);
end

--[[ ESP ]]--
do
	-- A more modular method of setting up the lines to be drawn
	local esplines = {}
	esplines.__index = esplines
	setmetatable(esplines, {
		__call = function(self)
			return setmetatable( { lines = {} }, self);
		end
	});
	function esplines:Add(lineID,lineText,lineColour,lineWeight)
		if not(lineID and lineText and lineColour and lineWeight) then
			error("Incorrectly formatted line added!",2)
		elseif lineWeight < 1 then
			error("lineWeight cannot be lower than 1!",2)
		end
		self.lines[lineID] = { text = lineText, color = lineColour, weight = lineWeight}
	end
	function esplines:Remove(lineID)
		self.lines[lineID] = nil
	end
	function esplines:Get(lineID)
		return self.lines[lineID]
	end
	function esplines:AdjustWeight(lineID,lineWeight)
		self.lines[lineID].weight = lineWeight
	end
	function esplines:ShiftWeightDown(amount,threshhold)
		if amount <= 0 then
			error("Don't do this.",2)
		end
		for id,line in pairs(self.lines) do
			if line.weight > threshhold then
				line.weight = line.weight + amount
			end
		end
	end
	function esplines:GetAll()
		local ret = {}
		for _,line in pairs(self.lines) do
			ret[#ret + 1] = line;
		end
		table.sort(ret, function(a,b) return a.weight < b.weight end);
		return ret;
	end
	function esplines:Kill()
		self.invalid = true;
	end
	function esplines:IsValid()
		return not (self.invalid or table.Count(self.lines) == 0);
	end

	-- To allow the penetration of cars with x-ray vizions
	local vehicles;
	hook.Add("Tick", "ESP Vehicle Ticking", function()
		vehicles = {};
		local i = 1;
		for _, ent in pairs(ents.GetAll()) do
			if (ent:IsValid() and ent:IsVehicle()) then
				vehicles[i] = ent;
				i = i + 1;
			end
		end
		vehicles[i] = lpl; -- Makes sure the visibility check doesn't hit us.
	end)
	-- Vars
	local tr, cent, fdist, dist, class, pos, spos, lpos, cam, alpha, centre, x, y, lines, db;
	function GM:HUDPaintESP()
		if (not lpl:Alive() or lpl._Sleeping) then
			return;
		end
		-- Vars
		tr, cent, fdist, dist, class, pos, spos, lpos, cam, alpha, centre, x, y, lines = nil;
		-- Unchanging
		fdist = self.Config["Talk Radius"] * 2;
		tr = util.TraceLine{
			start = EyePos();
			endpos = EyePos() + EyeVector() * fdist;
			filter = lpl;
		};
		if (IsValid(tr.Entity)) then
			cent = tr.Entity;
		end
		cam = self:IsUsingCamera();
		lpos = EyePos();
			
		-- Loop
		for _, ent in pairs(ents.GetAll()) do if (ent:IsValid()) then
			-- Prelims
			class, pos = ent:GetClass(), ent:LocalToWorld(ent:OBBCenter());
			spos = pos:ToScreen();
			dist = cam and 0 or pos:Distance(lpos);
			-- On-Screen Check
			if (spos.visible and dist <= fdist) then
				-- Setup for visibility check
				x,y = spos.x, spos.y;
				centre = false;
				if (ent == cent) then
					centre = true;
					x, y = self:GetScreenCenterBounce();
				elseif (ent == lpl and lpos == lpl:EyePos()) then
					-- When in a third person situation, your eyepos is different to your models, and you might want to see your own info.
					-- This prevents it being drawn otherwise by faking a trace.
					tr.Hit = true;		-- We did hit something on the visibility checfk
					tr.HitWorld = true;	-- And it was not the entity we wanted.
				else
					-- Run a trace to determine if we can see whatever it is we want to look at.
					tr = util.TraceLine( {
						start	= lpos;
						endpos	= pos;
						filter	= vehicles;
						-- This hitmask is bascially everything except windows.
						mask	= CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
						});
				end
				-- Visiblity check
				if (centre or not (tr.Hit and (tr.HitWorld or tr.Entity ~= ent))) then
					lines = esplines();
					if (ent.ESPPaint) then
						ent:ESPPaint(lines, pos, dist, centre);
					elseif (class == "class C_BaseEntity" and lookingat) then --  func_buttons show up as C_BaseEntity for some reason.
						local name = ent:GetNWString("Name");
						if (name == "") then
							name = "A Button";
						end
						lines:Add("Name", name, color_purpleblue, 1);
					else	
						ent:DefaultESPPaint(lines, pos, dist, centre)
					end
					gamemode.Call("AdjustESPLines", ent, class, lines, pos, dist, center);
					alpha = cam and 255 or (255 * (1 - dist / fdist));
					if (lines:IsValid()) then
						for _, line in pairs(lines:GetAll()) do
							y = self:DrawInformation(line.text, "ChatFont", x, y, line.color, alpha);
						end
					end
				end -- End of visibility check
			end -- End of on-screen check
		end end -- End of for loop
	end -- End of function

	function GM:HUDDrawTargetID()
		 return false
	end
	
	---
	-- TODO: desc
	function GM:AdjustESPLines(ent, class, lines, pos, dist, center)
	end
end
