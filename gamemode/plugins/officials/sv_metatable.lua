--
-- ~ Arrests, warrants etc ~
-- ~ Applejack ~
--
local plymeta = _R.Player;

local function warranttimer(ply)
	if (ply:IsValid()) then
		gamemode.Call("PlayerWarrantExpired", ply, ply:GetNWString("Warrant"));
		ply:UnWarrant();
	end
end

---
-- Applies a warrant to a player.
-- @param class The warrant type to apply. 'arrest' or 'search'.
-- @param time Optional, specify the time for the warrant to last
function plymeta:Warrant(class, time)
	gamemode.Call("PlayerWarranted", self, class, time);
	self._Warranted = class;
	self:SetNWString("Warrant", class);
	local expires = time or
                		(class == "arrest" and GM.Config["Arrest Warrant Expire Time"] or
                			GM.Config["Search Warrant Expire Time"]);
	-- Prevents any unplesant bugs due to user error.
	if expires <= 0 then
		expires = 0.1
	end
	self:SetCSVar(CLASS_LONG, "_WarrantExpireTime", CurTime() + expires);
	timer.Create(
		"Warrant Expire: " .. self:UniqueID(), expires, 1, warranttimer, self, class
	);
end

---
-- Removes the player's warrant
function plymeta:UnWarrant()
	gamemode.Call("PlayerUnwarranted", self);
	self._Warranted = nil;
	self:SetNWString("Warrant", "");
	timer.Stop("Warrant Expire: " .. self:UniqueID());
end

local function arresttimer(ply)
	if (not IsValid(ply)) then
		return
	end
	ply:UnArrest(true);
	ply:Notify("Your arrest time has finished!");
	ply:Spawn(); -- Let the player out of jail
end
---
-- Arrest a player so they cannot do most things, then unarrest them a bit later
-- @param time Optional - Specify how many seconds the player should be arrested for. Will default to the player's ._ArrestTime var
function plymeta:Arrest(time)
	if (self:Arrested()) then
		return
	end
	gamemode.Call("PlayerArrested", self);
	self.cider._Arrested = true;
	self:SetNWBool("Arrested", true);
	timer.Create(
		"UnArrest: " .. self:UniqueID(), time or self._ArrestTime, 1, arresttimer,
		self
	);
	self:SetCSVar(
		CLASS_LONG, "_UnarrestTime", CurTime() + (time or self._ArrestTime)
	);
	self:Incapacitate();
	self:TakeWeapons(true);
	self:StripAmmo();
	self:Flashlight(false);
	self:UnWarrant();
	self:UnTie(true);
end
---
-- Unarrest an arrested player before their timer has run out.
function plymeta:UnArrest(reset)
	if (not self:Arrested()) then
		return
	end
	gamemode.Call("PlayerUnArrested", self);
	self.cider._Arrested = false;
	self:SetNWBool("Arrested", false);
	self:SetCSVar(CLASS_LONG, "_UnarrestTime", 0);
	timer.Stop("UnArrest: " .. self:UniqueID());
	if (not reset) then
		self:Recapacitate();
		self:ReturnWeapons();
	end
end
