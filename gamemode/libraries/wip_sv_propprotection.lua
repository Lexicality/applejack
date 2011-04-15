--[[
	~ Prop Protectoin ~
	~ Moonshine ~
--]]
--[[
	My thanks to Spacetech for the original code.
	This is a heavily modified version of Simple Prop Protection.
	http://code.google.com/p/simplepropprotection
--]]



GM.Entities = {}

--[[ Settings ]]--
if not sql.TableExists("aj_propprotection") then
	sql.Query("CREATE TABLE propprotection("..
				"enabled INTEGER NOT NULL, ".. -- Are we enabled?
				"cleanup INTEGER NOT NULL, ".. -- Should disconnected player's props be cleaned up?
				"delay INTEGER NOT NULL, ".. -- Cleanup delay
				");");
	sql.Query("INSERT INTO aj_propprotection(enabled, delay) VALUES(1,120);");
end
local config = sql.QueryRow("SELECT * FROM propprotection LIMIT 1");
if (not (config and config.enabled and config.delay)) then
	ErrorNoHalt("["..os.date().."] Applejack Prop Protection: Config is corrupt!");
	config.enabled = 1;
	config.delay = 120;
end
--[[ Convars for the settings ]]--
local function changed(name,prev,new)
	if not tonumber(new) then return end
	config[name:sub(22)] = new
end
for name,value in pairs(config) do
	CreateConVar("cider_propprotection_"..name,value)
	cvars.AddChangeCallback("cider_propprotection_"..name,changed)
end

--[[ Adjustment of existing functions ]]--
if cleanup then
	if (not cleanup.oAdd) then
		cleanup.oAdd = cleanup.Add
	end
	function cleanup.Add(p,t,e)
		if IsValid(e) and p:IsPlayer() then
			e:MakePlayerOwner(p)
			e:SetSpawner(p)
		end
		cleanup.oAdd(p,t,e)
	end
end

--[[ Local Definitions ]]--
local disconnected = {} -- Disconnected players
local weirdtraces = { -- Tool modes that can be right-clicked to link them 
	wire_winch		= true,
	wire_hydraulic	= true,
	slider			= true,
	hydraulic		= true,
	winch			= true,
	muscle			= true
}
local line = "-- %-15s: %-68s --"
local function checkConstrainedEntities(ply,ent)
	for _,ent in ipairs(constraint.GetAllConstrainedEntities(ent)) do
		if not GM:PlayerCanTouch(ply,ent) then
			return false
		end
	end
	return true
end
local function deletePropsByID(id,name)
	for _,ent in ipairs(ents.GetAll()) do
		local x,y,z = ent:GetPPOwner()
		if z == id then
			if GM.Entities[ent] then
				ent:GiveToWorld()
			else
				ent:Remove()
			end
		end
	end
	disconnected[id] = nil
	if name then
		player.NotifyAll("%s's props have been cleaned up.",0,name)
	end
end
local function physhandle(ply, ent)
	return IsValid(ent) and gamemode.Call("PlayerCanTouch",ply,ent);
end
local function spawnHandler(ply, ent)
	ent:GiveToPlayer(ply)
	ent:SetSpawner(ply)
end
local function format(player,title,content)
	player:PrintMessage(HUD_PRINTCONSOLE,line:format(title,content))
end

--[[ Hooks ]]--
function GM:ClearProps(ply,silent)
	for _,ent in ipairs(ents.GetAll()) do
		if (ent:GetPPOwner() == ply) then
			if (self.Entities[ent]) then
				ent:GiveToWorld()
			else
				ent:Remove();
			end
		end
	end
	if (not silent) then
		player.NotifyAll("%s's props have been cleaned up.",0,ply:Name());
	end
end
function GM:PlayerCanTouch(ply, ent)
	if not tobool(config["enabled"])
	or ent:GetClass() == "worldspawn"
	or ent.SPPOwnerless
	then
		return true
	end
	local owner = ent:GetPPOwner()
	if not owner then
		ent:GiveToPlayer(ply)
		ply:Notify("You now own this prop.",0)
		return true
	elseif owner == GetWorldEntity() then
		return ply:IsAdmin() and tobool(config["adminabuse"])
	elseif owner == ply or owner:IsValid() and owner:IsPlayer() and owner:IsPPFriend(ply) then
		return true
	else
		return false
	end
end
function GM:CanTool(ply, tr, mode, nailee)
	-- Before we do anything, let's make it so people can point cameras at whatever they want.
	if (mode == "camera" or mode == "rtcamera") then
		return true;
	elseif (not self.BaseClass:CanTool(ply, tr, mode)) then -- Firstly, let's let sandbox decide if they can't do it
		return false;
	elseif (tr.HitWorld or not IsValid(tr.Entity)) then -- If sandbox says it's ok, we don't care about anything that's not an entity.
		return true;
	end
	local ent = tr.Entity;
	
	if (not gamemode.Call("PlayerCanTouch", ply, ent)) then
		return false;
	elseif (mode == "nail" and not nailee) then
		local line = util.TraceLine({
			start = tr.HitPos,
			endpos = tr.HitPos + tr.Normal * 16,
			filter = ent
		});
		if (IsValid(line.Entity) and not gamemode.Call("CanTool", ply, tr, mode, true)) then
			return false;
		end
	elseif (ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2)) then
		if (weirdtraces[mode]) then
			local line = util.TraceLine({
				start = tr.HitPos,
				endpos = tr.HitPos + tr.HitNormal * 16384,
				filter = ply
			});
			if (IsValid(line.Entity) and not gamemode.Call("CanTool", ply, tr, mode)) then
				return false;
			end
		elseif (mode == "remover" and not checkConstrainst(ply, ent)) then
			return false;
		end
		--[[ NOTE TO SELF: Add the door selling shit in door:OnRemove() in the stool, ]]--
	elseif (mode:sub(1,5) == "wire" and not ply:HasAccess("w")) then
		ply:ConCommand('gmod_toolmode ""\n');
		return false;
	elseif (IsValid(ent._Player) and not ply:IsAdmin()) then
		return false;
	elseif (mode ~= "remover" and not ply:IsAdmin()) then 
		local class = ent:GetClass();
		if (class:find("camera") or class:find("vehicle") or ent:IsDoor()) then
			return false
		end
	end
	self:Log(EVENT_BUILD,"%s used %s on a %s",ply:Name(),mode,ent:GetClass());
	return true;
end;

function GM:GravGunPunt(ply, ent)
	return physhandle(ply, ent) and ply:IsAdmin();
end

function GM:PhysgunPickup(ply, ent)
	if (not IsValid(ent)) then
		return false;
	elseif (not physhandle(ply, ent)) then
		return false
	elseif (ent.PhysgunPickup) then	
		return ent:PhysgunPickup(ply);
	elseif (ent.PhysgunDisabled) then
		return false;
	elseif (ent:IsVehicle()) then
		local model = ent:GetModel();
		if (not (player:IsAdmin() or model:find("chair") or model:find("seat"))) then
			return false;
		end
	elseif (ent:IsDoor()) then
		return false; -- physgunning doors always leads to trouble.
	elseif (ply:IsAdmin()) then
		if (ent:IsPlayer()) then
			if (ent:InVehicle()) then
				return false;
			end
			ent:SetMoveType(MOVETYPE_NOCLIP);
			ply._Physgunnin = true;
		end
		return true; -- Admins need to be able to pick stuff up.
	elseif (IsValid(ent._Player)) then -- Stop players grabbing ragdolls
		return false;
	elseif (ent:IsNPC()) then -- Don't want people picking up npcs, now do we?
		return false;
	elseif (ent:GetPos():Distance(ply:GetPos()) > self.Config["Maximum Pickup Distance"]) then
		return false; -- Stop people picking up things on the other side of the map!
	end
	-- Let's let sandbox have a go at them
	
	return self.BaseClass:PhysgunPickup(player, entity)
end;

-- Called when a player attempts to drop an entity with the physics gun.
function GM:PhysgunDrop(player, entity)
	if ( entity:IsPlayer() ) then
		entity:SetMoveType(MOVETYPE_WALK)
		player._Physgunnin = false
	end
end
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	if (ent:IsVehicle() and not ply:IsAdmin()) then
		return false
	end
	self.BaseClass:OnPhysgunFreeze( weapon, phys, ent, ply ) 
end

function GM:OnPhysgunReload(_,ply)
	local tr = ply:GetEyeTrace()
	if IsValid(tr.Entity) and not gamemode.Call("PlayerCanTouch",ply, tr.Entity) then	
		return false
	end
	return self.BaseClass:OnPhysgunReload(_,ply);
end;

function GM:GravGunPickupAllowed(ply, ent)
	if (not physhandler(ply, ent)) then
		return false;
	elseif (ent.GravGunPunt) then
		return ent:GravGunPickupAllowed(ply);
	end
	return true;
end
function GM:InitPostPostEntity()
	local i = 0;
	for _,ent in ipairs(ents.GetAll()) do
		if (not ent:IsPlayer()) then
			ent:GiveToWorld();
			i = i + 1;
			self.Entities[ent] = ent;
		end
	end
	MsgN("Moonshine: Prop Protection: "..i.." entities given to the world.");
end

hook.Add("PlayerAuthed", 			"Moonshine Prop Protection PlayerAuthed",			function(ply, sid, uid)
	disconnected[uid] = nil
	timer.Destroy("Prop Cleanup "..uid)
end)
hook.Add("SaveData",				"Moonshine Prop Protection SaveData",				function()
	local keys, values = "",""
	for name,value in pairs(config) do
		keys = keys..","..name
		values = values..","..tostring(tonumber(value) or 0)
	end
	keys,values = keys:sub(2),values:sub(2)
	sql.Query("UPDATE mshine_apropprotection SET "..keys..' = "'..values..'";')
end)
hook.Add("InitPostPostEntity",		"Moonshine Prop Protection InitPostPostEntity",		function()
end)
hook.Add("PlayerSpawnedSENT",		"Moonshine Prop Protection PlayerSpawnedSENT",		spawnHandler)	
hook.Add("PlayerDisconnected",		"Moonshine Prop Protection Disconnect Cleanup",		function(ply)
	timer.Create("Prop Cleanup "..ply:UniqueID(),tonumber(config["delay"]),1,deletePropsByID,ply:UniqueID(),ply:Name())
	disconnected[ply:UniqueID()] = true;
end)
hook.Add("PlayerSpawnedVehicle",	"Moonshine Prop Protection PlayerSpawnedVehicle",	spawnHandler)

--[[ Concommands ]]--
local COMMAND = GM:NewCommand();
COMMAND.Cmd = "ppfriends"
COMMAND.Syntax = "<add|remove|clear> [player]";
COMMAND.Args = 1;
COMMAND.Types = "String Player";
COMMAND.Callback = function(Caller, action, target)
	if (not( action == "add" or action == "remove" or action == "clear")) then
		return false, "Invalid action specified!";
	end
	if (action == "clear") then
		Caller:ClearPPFriends();
		return
	end
	if (not IsValid(target)) then
		return false,"No player specified!";
	end
	if (action == "add") then
		Caller:AddPPFriend(target);
	else
		Caller:RemovePPFriend(target);
	end
end
COMMAND:Register();

COMMAND.Cmd = "ppcleardisconnect";
COMMAND.Flags = "a";
COMMAND.Callback = function(Caller)
	local props = ents.GetAll();
	for id in pairs(disconnected) do
		for _,ent in ipairs(props) do
			if (IsValid(ent)) then
				local _,_,uid = ent:GetPPOwner();
				if (uid == id) then
					if (GM.Entities[ent]) then
						ent:GiveToWorld();
					else
						ent:Remove();
					end
				end
			end
		end
	end
	disconnected = {};
	player.NotifyAll("All disconnected players' props have been cleared up.",0);
end;
COMMAND:Register();

COMMAND.Cmd = "ppclearprops";
COMMAND.Syntax = "[player]";
COMMAND.Types = "Player";
COMMAND.Args = 0;
COMMAND.Callback = function(Caller, target)
	if (not IsValid(target)) then
		deletePropsByID(Caller:UniqueID());
	elseif (Caller:IsAdmin()) then
		deletePropsByID(target:UniqueID(),target:Name());
	end
end;
COMMAND:Register();

concommand.Add("propinfo",function(p)
	local ent = p:GetEyeTrace().Entity
	if not ValidEntity(ent) then
		p:Notify("No entity.",0)
		return
	elseif not p:HasAccess("m") then
		p:Notify("You do not have access to that.",1)
		return
	end
	--mshine.player.notify(p,( tostring( ent ).."["..ent:GetModel().."]"),0)
	if ent:IsPlayer() then
		p:Notify(ent:Name()..": "..ent:SteamID().." ("..ent:IPAddress()..")",0)
		return
	end
	local _,owner = ent:GetPPOwner()
	if owner and owner ~= "" then
		local words = tostring(ent).." is owned by "..owner
		local spawner = ent:GetSpawner()
		if spawner and spawner ~= "" then
			words = words.." and was spawned by "..spawner
		end
		p:Notify(words,0)
	else
		p:Notify(tostring(ent).." is not owned.")
	end
	if not mshine.player.hasAccess(p,"D") then return end
	p:Notify( tostring( ent ).."["..ent:GetModel().."]",0)
	local pos = ent:GetPos()
	local ang = ent:GetAngles()
	local r,g,b,a = ent:GetColor()
	p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------"	)
	p:PrintMessage(HUD_PRINTCONSOLE, "--                                       Prop info                                       --"	)
	p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------"	)
	format(p,"Info",		tostring( ent ) 																						)
	format(p,"Model",		'"'..tostring( ent:GetModel() )..'"' 																	)
	p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------"	)
	format(p,"Position",	"Vector("..math.DecimalPlaces(pos.x,4)..", "..math.DecimalPlaces(pos.y,4)..", "..math.DecimalPlaces(pos.z,4)..")" )
	format(p,"Angle",		"Angle("..math.Round(ang.p)..", "..math.Round(ang.y)..", "..math.Round(ang.r)..")"						)
	format(p,"Colour",		"Color("..r..", "..g..", "..b..", "..a..")"																)
	format(p,"Material",	tostring( ent:GetMaterial() ) 																			)
	format(p,"Size",		tostring( ent:OBBMaxs() - ent:OBBMins() )																)
	format(p,"Radius",		tostring( ent:BoundingRadius() ) 																		)

	local ph = ent:GetPhysicsObject()
	if ValidEntity(ph) and p:HasAccess"H" then
		p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------"	)
		p:PrintMessage(HUD_PRINTCONSOLE, "--                                        PhysObj                                        --"	)
		p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------"	)
		format(p,"Mass",			tostring(ph:GetMass())																				)
		format(p,"Inertia",			tostring(ph:GetInertia())																			)
		format(p,"Velocity",		tostring(ph:GetVelocity())																			)
		format(p,"Angle Velocity",	tostring(ph:GetAngleVelocity())																		)
		format(p,"Rot Damping",		tostring(ph:GetRotDamping())																		)
		format(p,"Speed Damping",	tostring(ph:GetSpeedDamping())																		)
	end
	p:PrintMessage(HUD_PRINTCONSOLE, "-------------------------------------------------------------------------------------------" 		)
end)
