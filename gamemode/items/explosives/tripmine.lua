--[[
	~ TreepMine ~
	~ Applejack ~
--]]


ITEM.Name			= "Tripmine";
ITEM.Size			= 2;
ITEM.Cost			= 5000;
ITEM.Model			= "models/weapons/w_slam.mdl";
ITEM.Batch			= 10;
ITEM.Store			= true;
ITEM.Plural			= "Tripmines";
ITEM.Description	= "Will explode if someone passes through it's beam.";
ITEM.Base			= "item"
ITEM.NoVehicles		= true;

-- Called when a player uses the item.
function ITEM:onUse(ply)
	local trace	= ply:GetEyeTraceNoCursor();
	if (not (trace.Hit and trace.HitWorld and trace.HitPos:Distance(ply:GetPos()) <= 128)) then
		ply:Notify("You must place a tripmine on a wall close to you!",1);
		return false;
	end
	local ent = ents.Create("npc_tripmine");
	ent:SetAngles(trace.HitNormal:Angle() + Angle(90, 0, 0));
	ent:SetPos(trace.HitPos + ent:GetUp() * 2);
	ent._planter = ply;
	ent:SetSolid(false);
	ent:Spawn();
	cider.propprotection.PlayerMakePropOwner(ply, ent, true); --Let admins know who planted the mine
	ent.PhysgunDisabled	= true;
	ent.m_tblToolsAllowed	= {};
end
