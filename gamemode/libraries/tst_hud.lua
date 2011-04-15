local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z; -- ust in case lol
local lpl;
surface.SetFont("DefaultFixed");
s,t = surface.GetTextSize("100%");
c = false;
j = 6;
local sh,sw = ScrH(), ScrW();
local function dc(c)
	return c.r, c.g, c.b, c.a;
end
---------------------------------------------------------------------------------------------------
local bars,newbar,barprep = {};
do -- Bars
local function pad(g)
	return string.format("%3i%%", g);
end
local bw = 108;
local bh = 18;
local by = sh - 20;
local th = (bh - t) / 2 + 1
local t2h = (bh - 8 - t) / 2 + 1
local ix = (s - 16) / 2;
local iy = (bh - 16) / 2;
local function p(self)
	g = self:g();
	if (g == -1) then return end; -- Allow bar hiding
	x,y = 0,by;
	w,h = --[[(c and ]]bw--[[) or (g ~= 0 and g + 8) or 0]], bh;
	surface.SetDrawColor(0,0,0,150);
	surface.DrawRect(x,y,w+s,h);
	surface.SetTextColor(255,255,255,255);
	surface.SetFont("DefaultFixed");
--	surface.SetTextPos(x,y + th);
--	surface.DrawText(pad(g));
	x = s
	i = self.i
	if (i and false) then
		surface.SetDrawColor(255,255,255,255);
		surface.SetTexture(i);
		surface.DrawTexturedRect(ix, y + iy, 16, 16);
	end
	x = x + 4;
	y = y + 4;
	h = h - 8;
	w = w - 8;
	if (g ~= 0) then
		surface.SetDrawColor(dc(self.c));
		surface.DrawRect(x,y,g,h);
	end
	z = (self.tf and self:tf() or self.w);
	--if (c or (z <= w) ) then
		x = x + (w - z) / 2
		surface.SetTextPos(x,y + t2h);
		surface.DrawText(self.t);
	--end
	by = by - bh - 5;
end		

function newbar(icon, txt, col, getamt, tf)
	surface.SetFont("DefaultFixed");
	w = surface.GetTextSize(txt)
	bars[#bars+1] = {
		i = icon and surface.GetTextureID(icon);
		y = by;
		p = p;
		c = col;
		t = txt;
		tf = tf;
		g = getamt;
		w = w;--tf and (bw - 8) or ((bw - w) / 2 + 1);
	--	z = w;
	}
end
function barprep()
	by = sh - 20;
end
end
---------------------------------------------------------------------------------------------------
newbar("gui/silkicons/heart","Health: 100", Color(255, 0, 0), function(self)
	self.h = lpl:Health();
	h = math.min(self.h, 100);
	return self.h == 100 and -1 or h;
end, function(self)
	self.t = "Health: " .. self.h
	return self.w
end);
--newbar("Sine", Color(120, 0, 120), function() return (math.sin(CurTime()) + 1 ) * 50; end);
--newbar("cos", Color(0, 120, 120), function() return (math.cos(CurTime()) + 1 ) * 50; end);
a = {};
newbar("gui/silkicons/package","Ammo", Color(0, 0, 255), function (self)
	w = lpl:GetActiveWeapon();
	self.a,self.b,self.m = nil;
	if (not IsValid(w)) then 
		return -1;
	end
	f = w:GetClass();
	l = w:Clip1();
	m = a[f];
	if (not m or l > m) then
		a[f] = l;
		m = l
	end
	if (m < 1) then
		return -1;
	end
	self.a,self.m,self.b = l, m, lpl:GetAmmoCount(w:GetPrimaryAmmoType());
	return (l / m) * 100;
end, function(self)
	if (self.a ~= nil) then
		f = self.a .. "/" .. self.m .. " (" .. self.b .. ")";
	end
	self.t = f;
	return surface.GetTextSize(f)
end);
---------------------------------------------------------------------------------------------------
local boxes, addbox, boxprep = {}
do -- Infoboxes
local bh = 20;
local bw, th = surface.GetTextSize("12345678901234567890123456789012345678901234567890");
local by = 10;
local ix = (s - 16) / 2;
local iy = (bh - 16) / 2;
local ty = (bh - th) / 2;
local function p(self)
	t = self:t();
	if (t == -1) then return end; -- Allow bar hiding
	x,y = 0, by;
	w,h = bw, bh;
	surface.SetDrawColor(0,0,0,150);
	surface.DrawRect(x,y,w+s,h);
	x = s;
	i = self.i
	if (i) then
		surface.SetDrawColor(255,255,255,255);
		surface.SetTexture(i);
		surface.DrawTexturedRect(ix, y + iy, 16, 16);
	end
	surface.SetFont("DefaultFixed");
	surface.SetTextColor(255,255,255,255);
	surface.SetTextPos(x + (w - surface.GetTextSize(t)) / 2, y + ty);
	surface.DrawText(t);
	by = by + bh + 2;
end
function addbox(icon, gt)
	boxes[#boxes+1] = {
		i = icon and surface.GetTextureID(icon);
		t = gt;
		p = p;
	}
end
function boxprep()
	by = 10;
end
end
---------------------------------------------------------------------------------------------------
addbox("gui/silkicons/user", function(self)
	return "Name: " .. lpl:Name():sub(1,43);
end);
do
local mi,fi = surface.GetTextureID("gui/silkicons/male"), surface.GetTextureID("gui/silkicons/female");
addbox("gui/silkicons/male", function(self)
	t = lpl._Gender or "???"
	if (t ~= self.o) then
		if (t == "Female") then
			self.i = fi;
		else
			self.i = mi;
		end
		self.o = t;
	end
	return "Gender: " .. t;
end);
end
addbox("gui/silkicons/group", function(self)
	t = lpl:GetNWString("Clan");
	if (t == "") then
		return -1;
	end
	return "Clan: " .. t;
end);
---------------------------------------------------------------------------------------------------
local addhint,painthints
do
local hintfont = "TabLarge";
surface.SetFont(hintfont);
w,h = surface.GetTextSize("M");
local hints = {}
local hh = h + 10;
local hy = sh - hh - 5;
local hc = 1;
local hl = 5;
local ty = 5;
local tx = 7;
local function p(self, time)
	if (hy < 0) then return end
	w,h = self.w + j + tx, hh;
	x,y = self.x, hy
	if (not self.b) then
		x = x - 2;
		m = sw-w
		if (x <= m) then
			self.b = time + hl;
			self.k = true
			x = m;
		end
	elseif (self.b < time) then
		x = x + 1;
		self.k = false
		if (x == sw) then
			return false;
		end
	else
		o = ((self.b - time) / hl) * hh
		surface.SetDrawColor(200,200,200,255);
		surface.DrawRect(sw-j,hy+hh-o,j,o);
	end
	self.x = x;
	surface.SetDrawColor(0,0,0,220);
	surface.DrawRect(x, y, w, h);
	if (self.k) then
		if (self.s) then
			surface.PlaySound(self.s)
			self.s = nil;
		end
		if (self.c) then
			self.e = self.e or (time + 0.5);
			e = self.e - time;
			if (e <= 0.25) then
				surface.SetDrawColor(dc(self.c));
				surface.DrawRect(x,y,w,h);
				if (e <= 0) then
					self.e = time + 0.5
					self.f = self.f and (self.f + 1) or 1;
					if (self.f == 2) then
						self.c = nil;
					end
				end
			end
		end
	end
	surface.SetTextPos(x+tx,y+ty);
	surface.DrawText(self.t);
end
function painthints()
	surface.SetDrawColor(0,0,0,150);
	surface.DrawRect(sw-j,0,j,sh);
	hy = sh / 2 + hh;
	local time = RealTime();
	surface.SetFont(hintfont);
	surface.SetTextColor(255,255,255,255);
	for _, hint in pairs(hints) do
	--	PrintTable(hint);
		if (p(hint,time) == false) then
			hints[_] = nil;
		else
			hy = hy - hh - 5;
		end
	end
end
function addhint(class, text, sound)
	surface.SetFont(hintfont);
	hints[hc] = {
		c = class;
		t = text;
		x = sw;
		w = surface.GetTextSize(text) + j;
		i = hc;
		s = sound;
	}
	hc = hc + 1;
end
concommand.Add("addhint",function(p,c,a) addhint(Color(255,0,0,120),a[1],"buttons/button10.wav"); end);
end
---------------------------------------------------------------------------------------------------
local function paint()
	lpl = lpl or LocalPlayer();
	w,h = sw,sh;
	surface.SetDrawColor(0,0,0,150);
	surface.DrawRect(0,0,s,h);
	barprep()
	for _, bar in ipairs(bars) do
		bar:p();
	end
	boxprep();
	for _, box in ipairs(boxes) do
		box:p();
	end
	painthints();
end
local function nohud(name)
	if name == "CHudHealth"
	or name == "CHudBattery"
	or name == "CHudSuitPower"
	or name == "CHudAmmo"
	or name == "CHudSecondaryAmmo" then
		return false;
	end
end
local function cxo() c = true; end
local function cxc() c = false; end
---------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "TestHud", paint);
hook.Add("HUDShouldDraw", "TestHud", nohud);
--hook.Add("OnContextMenuOpen", "TestHud", cxo);
--hook.Add("OnContextMenuClose", "TestHud", cxc);