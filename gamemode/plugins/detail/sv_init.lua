--
-- ~ Detail Plugin ~
-- ~ Applejack ~
--
include("sv_data.lua")

PLUGIN.Name = "Details";

function PLUGIN:InitPostEntity()
	timer.Simple(FrameTime() * 4,self.FrameOne,self);
end
function PLUGIN:FrameOne()
	local filtr = ents.Create( "filter_activator_name" );
	filtr:SetKeyValue( "targetname", "aj_details" );
	filtr:SetKeyValue( "negated", "1" );
	filtr:Spawn();
	local mapname = game.GetMap():lower();
	local ent;
	if (self.ToSpawn[mapname]) then
		for _,tab in pairs(self.ToSpawn[mapname]) do
			ent = ents.Create("prop_physics");
			if (IsValid(ent)) then
				ent:SetModel (tab[1]);
				ent:SetAngles(tab[2]);
				ent:SetPos   (tab[3]);
				if(tab[4])then
					ent:SetColor(tab[4]);
				end;
				ent.PhysgunDisabled = true;
				ent.m_tblToolsAllowed = {};
				ent:Spawn();
				local phys = ent:GetPhysicsObject();
				if (IsValid(phys)) then
					phys:EnableMotion(false);
				else
					ErrorNoHalt("Applejack (Details): Model has no physics! "..tab[1].."\n");
				end
				ent:Fire ( "setdamagefilter", "aj_details", 0 );
				hook.Call("PropSpawned", GM, tab[1], ent);
				ent:SetPPOwner(NULL);
				GM.Entities[ent] = ent;
			else
				ErrorNoHalt("Applejack (Details): Couldn't create model "..tab[1].."!");
			end
		end
	end
	timer.Simple(FrameTime() * 2,self.FrameTwo,self,mapname);
end
function PLUGIN:FrameTwo(mapname)
	if (self.Effects[mapname]) then
		for _,tab in pairs(self.Effects[mapname]) do
			ent = ents.Create("prop_effect");
			if (IsValid(ent)) then
				ent:SetModel (tab[1]);
				ent:SetAngles(tab[2]);
				ent:SetPos   (tab[3]);
				ent.PhysgunDisabled = true;
				ent.m_tblToolsAllowed = {};
				ent:Spawn();
				ent:Activate();
				ent:SetDTBool(3,true);
				ent:SetPPOwner(NULL);
				GM.Entities[ent] = ent;
			else
				ErrorNoHalt("Applejack (Details): Couldn't create model "..tab[1].."!");
			end
		end
	end
	timer.Simple(FrameTime() * 2,self.FrameThree,self,mapname);
end
function PLUGIN:FrameThree(mapname)
	if (self.Vehicles[mapname]) then
		local VehicleList = list.Get( "Vehicles" );
		local vehicle;
		for _,tab in pairs(self.Vehicles[mapname]) do
			vehicle = VehicleList[tab[1]];
			if (not vehicle) then
				ErrorNoHalt("Applejack (Details): No Such vehicle "..tab[1].."!");
			else
				ent = ents.Create(vehicle.Class);
				if (not IsValid(ent)) then
					ErrorNoHalt("Applejack (Details): Could not create vehicle "..tab[1].."!");
				else
					ent:SetModel( vehicle.Model )
					-- Fill in the keyvalues if we have them
					if (vehicle.KeyValues ) then
						for k, v in pairs( vehicle.KeyValues ) do
							ent:SetKeyValue( k, v );
						end
					end
					ent:SetAngles(tab[2]);
					ent:SetPos   (tab[3]);
					ent:Spawn    ();
					ent:Activate ();
					ent.PhysgunDisabled = true;
					ent.m_tblToolsAllowed = {};
					ent.VehicleName 	= tab[1];
					ent.DisplayName		= vehicle.Name;
					ent.VehicleTable 	= vehicle;
					if (vehicle.Members) then
						table.Merge(ent, vehicle.Members);
					end
					local phys = ent:GetPhysicsObject();
					if (IsValid(phys)) then
						phys:EnableMotion(false);
					else
						ErrorNoHalt("Applejack (Details): Vehicle model has no physics! "..tab[1]);
					end
					ent:Fire("setdamagefilter", "aj_details", 0);
					ent:SetPPOwner(NULL);
					GM.Entities[ent] = ent;
				end
			end
		end
	end
	timer.Simple(FrameTime() * 2,self.FrameFour,self,mapname);
end
function PLUGIN:FrameFour(mapname)
	if (self.Doors[mapname]) then
		for _,tab in pairs(self.Doors[mapname]) do
			ent = ents.Create(tab[1]);
			if (not IsValid(ent)) then
				ErrorNoHalt("Applejack (Details): Could not create a door with class "..tab[1].."!");
			else
				ent:SetAngles(tab[2]);
				ent:SetModel (tab[3]);
				ent:SetPos   (tab[4]);
				if (tab[1] == "prop_dynamic") then
					ent:SetKeyValue("solid",		6   );
					ent:SetKeyValue("MinAnimTime",	1   );
					ent:SetKeyValue("MaxAnimTime",	5   );
				else
					ent:SetKeyValue("hardware",		1   );
					ent:SetKeyValue("distance",		90  );
					ent:SetKeyValue("speed",		100 );
					ent:SetKeyValue("returndelay",	-1  );
					ent:SetKeyValue("spawnflags",	8192);
					ent:SetKeyValue("forceclosed",	0   );
				end
				ent:Spawn   ();
				ent:Activate();
				ent.PhysgunDisabled = true;
				ent.m_tblToolsAllowed = {};
				ent._DoorState = "closed";
				ent._Autoclose = 30;
				ent:MakeOwnable();
				ent:SetPPOwner(NULL);
				ent:SetNWString("Name",tab[5]);
			end
		end
	end
end
