--[[
	~ Vehicles Plugin / SV ~
	~ Applejack ~
--]]

if (PLUGIN.Abort) then return end

local function getnewpos(pos, ang, apos)
	return pos + ang:Forward() * apos.x + ang:Right() * apos.y + ang:Up() * apos.z;
end

local carz = {};
cider.command.add("cleancars","a",0,function()
	for _,ent in pairs(carz) do
		if (IsValid(ent)) then
			ent:Remove();
		end
		carz[_] = nil;
	end
end, "Admin Commands", "", "Delete all cars on the server");

vu_enablehorn = CreateConVar( "vu_enablehorn", "1")
function PLUGIN:MakeVehicle(player, pos, ang, model, class, vname, vtable)
	local ent = ents.Create( class )
	if (not IsValid(ent)) then
		error("["..os.date().."] Applejack Vehicles Plugin: could not spawn a "..class.."!");
	end
	
	ent:SetModel(model);
	ent:SetAngles(ang);
	ent:SetPos(pos);
	
	if (vtable and vtable.KeyValues) then
		for k, v in pairs(vtable.KeyValues) do
			ent:SetKeyValue(k, v);
		end
	end
	
	if ( vtable.Members ) then
		table.Merge( ent, vtable.Members )
		duplicator.StoreEntityModifier( ent, "VehicleMemDupe", vtable.Members );
	end
	
	ent:Spawn();
	ent:Activate();
	
	local p = ent:GetPhysicsObject();
	if (not IsValid(p)) then
		ent:Remove();
		player:Notify("You cannot spawn that car at this time.",1);
		error("No physics for model '"..model.."'! ("..ITEM.name..","..player:Name()..")");
	elseif (p:IsPenetrating()) then
		player:Notify("You cannot spawn your car there!", 1);
		ent:Remove();
		return NULL;
	end
	
	ent.VehicleName  = vname;
	ent.VehicleTable = vtable;
	ent.NoClear		 = true;
	-- We need to override the class in the case of the Jeep, because it 
	-- actually uses a different class than is reported by GetClass
	ent.ClassOverride= class;
	gamemode.Call( "PlayerSpawnedVehicle", player, ent );
	return ent;
end

local sky, ang, spawnstep = Vector(0,0,100000), Angle(0,0,0), Vector(0,0,20);
local toolfunc = function( self, ply, trace, mode )
	return ply:IsSuperAdmin() or mode == "remover" and ply:IsAdmin();
end
function PLUGIN:SpawnCar(ply, item)
	if (item.CanSpawn and not item:CanSpawn(ply)) then
		return false;
	end
	if (IsValid(ply._Vehicle)) then
		ply:Notify("You may not have two cars out at once. Go find your "..ply._Vehicle.RPName.."!", 1);
		return false;
	elseif ((ply._NextVehicleSpawn or 0) > CurTime()) then
		ply:Notify("You must wait another "..string.ToMinutesSeconds(ply._NextVehicleSpawn-CurTime()).." minutes before you can spawn your car again.", 1);
		return false;
	end
	
	local car = list.Get"Vehicles"[item.VehicleName];
	if (not car) then
		ply:Notify("Invalid car referenced!",1);
		error("["..os.date().."] Applejack Vehicles Plugin: Error spawning a "..item.Name..": Invalid vehicle type specified: '"..item.VehicleName.."'.");
	end
	local name = car.RPName or car.Name;
 	local tr = ply:GetEyeTraceNoCursor() ;
 	local trace = util.QuickTrace( tr.HitPos, sky );
	if (trace.Hit and not trace.HitSky) then
		ply:Notify("You must spawn your "..car.Name.." under open sky!", 1);
		return false;
	end
	ang.yaw = ply:GetAngles().yaw + 180;
	
	local ent = self:MakeVehicle( ply, tr.HitPos + spawnstep, ang, car.Model, car.Class, item.VehicleName, car );
	if (not IsValid(ent)) then
		return;
	end
	cider.propprotection.PlayerMakePropOwner(ply,ent);
	ent.CanTool = toolfunc;
	ent._LockpickHits = GM.Config["Maximum Lockpick Hits"] * 2 + 5; -- Thus making cars a hell of a lot harder to pick. ;D
	ent:Lock();
	ply._Vehicle = ent;
	table.insert(carz,ent);
	return ent;
end

function PLUGIN:PlayerSpawnedVehicle(ply, car)
	local pos, ang = car:GetPos(), car:GetAngles();
	car:SetUseType(SIMPLE_USE);
	if (not car.VehicleTable) then return end
	local tab = car.VehicleTable;
	if (tab.Ownable) then
		car:MakeOwnable();
		car:GiveToPlayer(ply);
	end if (tab.Skin) then
		car:SetSkin(tab.Skin);
	end
	car.RPName = tab.RPName or tab.Name;
	car:SetNWString("RPName",car.RPName);
	car:SetNWString("VehicleName",car.VehicleName);
	if (tab.Passengers) then
		local data = list.Get"Vehicles"[tab.SeatType];
		if (not data) then
			error("Invalid SeatType definition '"..tab.SeatType.."' in "..tab.Name.."!");
		end
		local seat;
		for i,v in ipairs(tab.Passengers) do
			seat = ents.Create"prop_vehicle_prisoner_pod";
			if (not IsValid(seat)) then
				error("Canont spawn seat entity!")
			end
			seat:SetModel(data.Model);
			seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
			seat:SetAngles(ang + v.Ang);
			seat:SetPos(getnewpos(pos, ang, v.Pos));
			seat:Spawn();
			seat:Activate();
			seat:SetParent(car);
			seat:Fire("lock", "", 0);
			seat:SetCollisionGroup(COLLISION_GROUP_WORLD);
			if (tab.HideSeats) then
				seat:SetColor(color_transparent);
			end if (data.Members) then
				table.Merge(seat, data.Members);
			end if (data.KeyValues) then
				for k, v in pairs(data.KeyValues) do
					seat:SetKeyValue(k, v);
				end
			end
			seat.VehicleName = "Seat";
			seat.VehicleTable = data;
			seat.ClassOverride = "prop_vehicle_prisoner_pod"
			seat._IsSeat = true;
			seat:DeleteOnRemove(car);
			tab.Passengers[i].Ent = seat;
		end
	end
end

function PLUGIN:CanManufactureCar(ply,item)
	if ((ply.cider._Inventory[item.UniqueID] or 0) >= 1) then
		ply:Notify("You cannot own more than 1 "..item.Name.."!", 1);
	elseif (not cider.inventory.canFit(ply, item.Size)) then
		ply:Notify("You do not have enough inventory space to buy this!", 1);
	else
		return true;
	end
	return false;
end

function PLUGIN:ManufactureCar(ply, ent, item)
	cider.inventory.update(ply, item.UniqueID, 1);
	ply:Notify("Your "..item.Name.." has been delivered to your inventory.", 2);
	ent:Remove();
end

function PLUGIN:SellCar(ply, item)
	if (IsValid(ply._Vehicle) and ply._Vehicle.VehicleName == item.VehicleName) then
		ply:Notify("You cannot sell your "..item.Name.." while it is still spawned!", 1);
		return false;
	end
	return true;
end

function PLUGIN:PickupCar(ply, item)
	if (not (ply:InVehicle() and ply:GetVehicle() == ply._Vehicle)) then
		ply:Notify("You must be in your "..item.Name.." to pick it up!", 1);
		return false;
	end
	ply:ExitVehicle();
	ply._Vehicle:Remove();
	ply._NextVehicleSpawn = CurTime() + 300;
	GM:Log(EVENT_ITEM,"%s put their %s back into their inventory.",ply:Name(),item.Name);
	return true;
end

local ignores	= {"predicted_viewmodel","physgun_beam","keyframe_rope"};
local function checkpos(ply,car,pos)
	enttab = ents.FindInSphere(pos,16);
	for k, ent in ipairs(enttab) do
		if (ent:IsWeapon()) then
			enttab[k] = nil;
		else
			for _,v in ipairs(ignores) do
				if (ent:GetClass() == v) then
					enttab[k] = nil;
					break;
				end
			end
		end
	end
	--print(pos, util.PointContents(pos));
	if (table.Count(enttab) == 0 and util.IsInWorld(pos) and car:VisibleVec(pos)) then
		--print("got")
		return pos
	elseif (ply:HasAccess("D")) then
		--print("missed",util.IsInWorld(pos), car:VisibleVec(pos))
		--PrintTable(enttab);
		ply:ConCommand("drawcross "..pos.x.." "..pos.y.." "..pos.z)
	end
end

local exits		= {"exit1", "exit2", "exit3", "exit4", "exit5", "exit6"};
local function doexit(ply, icar)
	local car = icar or ply:GetVehicle();
	if (not IsValid(car)) then
		-- We might potentially have been passed a null for icar.
		if (not IsValid(icar) and IsValid(ply:GetVehicle())) then
			car = ply:GetVehicle();
		else -- ok, something's gone wrong. Bail out.
			return;
		end
	end
	local par = car:GetParent();
	if (IsValid(par) and par:IsVehicle()) then
		car = par;
	end
	par = nil;
	if (car._Locked) then
		return;
	end
	if (ply:InVehicle()) then
		ply:ExitVehicle();
	end
	if (ply:InVehicle()) then -- You'd think this was unnecessary, but shit happens. :/
		timer.Simple(0,doexit,ply,car);
		error(tostring(ply).." has not left their vehicle. Retrying in one frame.");
	end
	local tab = car.VehicleTable;
	if (not tab) then -- If there is no vehicle table, then it's been hard spawned by a noob.
		error("Vehicle spawned without a vehicle table: "..tostring(car));
	end
	local exitpos
	if (tab.Customexits) then
		local pos, ang = car:GetPos(), car:GetAngles();
		for i, v in ipairs(tab.Customexits) do
			exitpos = getnewpos(pos, ang, v);
			exitpos = checkpos(ply, car, exitpos);
			if exitpos then
				ply:SetPos(exitpos);
				return
			end
		end
	end
	for _,v in ipairs(exits) do
		exitpos = car:GetAttachment(car:LookupAttachment(v));
		if (exitpos and exitpos.Pos) then
			exitpos = checkpos(ply, car, exitpos.Pos);
			if exitpos then
				ply:SetPos(exitpos);
				return
			end
		end
	end
end

function PLUGIN:PlayerUse(ply, ent)
	if (not ent:IsVehicle()) then
		return;
	elseif (ply:InVehicle() or ply:KnockedOut()) then
		return false;
	elseif (ply:Blacklisted("cat", CATEGORY_VEHICLES) > 0) then
		ply:BlacklistAlert("cat", CATEGORY_VEHICLES, GAMEMODE:GetCategory(CATEGORY_VEHICLES).Name);
		return false;
	end
	local ang = ent:GetAngles();
	if (ent._Locked) then
		if (math.abs(ang.r) > 10) then
			ang.r,ang.p = 0,0;
			ent:SetAngles(ang);
		end
		return false;
	end
	local tab = ent.VehicleTable
	if (not tab) then return end
	if (GM.Config["Car Doors"] and tab.Doors) then
		local pos = ent:WorldToLocal(ply:GetEyeTrace().HitPos);
		local success;
		for _,door in ipairs(tab.Doors) do
			local a,b,c = door.topleft, door.bottomright, pos
			if not (c.z < math.min(a.z,b.z) or c.z > math.max(a.z,b.z) or
					c.x < math.min(a.x,b.x) or c.x > math.max(a.x,b.x) or
					c.y < math.min(a.y,b.y) or c.y > math.max(a.y,b.y)) then
				success = true;
				break
			end
		end
		if (not success) then
			return false;
		end
	end if (tab.Passengers) then
		if (not IsValid(ent:GetDriver())) then
			return true; -- No one's driving? Let's get in!
		end
		for _,v in ipairs(tab.Passengers) do
			if (IsValid(v.Ent) and not IsValid(v.Ent:GetDriver())) then
				v.Ent:Fire("unlock","",0);
				ply:EnterVehicle(v.Ent);
				v.Ent:Fire("lock","",10);
				return true; -- odd \hit happens if we don't do this. :/
			end
		end
		return false; -- It seems all the seats are occupied.
	end
end

local function repositionplayer(ply,car)
	ply:SetParent();
	ply:SetPos(getnewpos(car:GetPos(), car:GetAngles(), car.VehicleTable.AdjustSitPos));
	ply:SetParent(car);
end

--[[
umsg.PoolString("setupviews");
function PLUGIN:PlayerEnteredVehicle(ply, car, role)
	SendUserMessage("setupviews",ply,car.VehicleName);
end
--]]
--[[
umsg.PoolString"ClearViewMod";
umsg.PoolString"ViewModFP";
umsg.PoolString"ViewModTP";
function PLUGIN:PlayerEnteredVehicle(ply, car, role)
	SendUserMessage("ClearViewMod", ply);
	if (not car.VehicleTable) then return end
	if (car.VehicleTable.AdjustSitPos) then
		timer.Simple(0,repositionplayer,ply,car)
	end
	if (not car.VehicleTable.ModView) then return end
	local tab = car.VehicleTable.ModView;
	if (tab.FirstPerson) then
		SendUserMessage("ViewModFP", ply, tab.FirstPerson);
	end if (tab.ThirdPerson) then
		local enttab = {ply,car};
		local ptab = car.VehicleTable.Passengers;
		local parent = car:GetParent()
		if (IsValid(parent)) then
			table.insert(enttab,parent);
			if (not ptab and parent:IsVehicle() and parent.VehicleTable) then
				ptab = car:GetParent().VehicleTable.Passengers;
			end
		end
		if (ptab) then
			for _,v in ipairs(ptab) do
				table.insert(enttab,v.Ent);
			end
		end
		table.Add(enttab,constraint.GetAllConstrainedEntities(car));
		umsg.Start("ViewModTP",ply);
		umsg.Char(#enttab);
		for _,ent in ipairs(enttab) do
			umsg.Entity(ent);
		end
		umsg.Short(tab.ThirdPerson.Out);
		umsg.Short(tab.ThirdPerson.Up);
		umsg.End();
	end
end
--]]

function PLUGIN:KeyPress(ply, key)
	if (key == IN_USE and ply:InVehicle()) then
		doexit(ply);
		return false; -- Waiting for source to do this is unreliable. I will do the exit myself.
	end
end

concommand.Add("HonkHorn", function(ply)
	ply._NextHonk = ply._NextHonk or CurTime();
	if (ply._NextHonk > CurTime()) then
		return false;
	elseif (not ply:IsSuperAdmin()) then
		ply._NextHonk = CurTime() + 5;
	end
	if (ply:InVehicle() and vu_enablehorn:GetInt() ~= 0) then
		local car = ply:GetVehicle();
		if (car.VehicleTable and car.VehicleTable.Horn) then
			car:EmitSound(car.VehicleTable.Horn.Sound, 100, car.VehicleTable.Horn.Pitch);
		end
	end
end);

concommand.Add("LockCar", function(ply)
	if (ply:InVehicle() and ply:GetVehicle():HasAccess(ply)) then
		ply:GetVehicle():Lock();
		ply:EmitSound("doors/door_latch3.wav");
	end
end);

concommand.Add("UnLockCar", function(ply)
	if (ply:InVehicle() and ply:GetVehicle():HasAccess(ply)) then
		ply:GetVehicle():UnLock();
		ply:EmitSound("doors/door_latch3.wav");
	end
end);

hook.Add("PlayerDisconnected", "Ajack Vehicle PlayerDisconnected",function(ply)
	if (IsValid(ply._Vehicle)) then
		ply._Vehicle:Remove();
	end
end);