--
-- ~ Head-Bob plugin ~
-- ~ Moonshine ~
--
PLUGIN.Name = "Headbob";

local a, b = 0, 0;
function PLUGIN:CalcView(ply, origin, angles, fov)
	if (IsValid(ply:GetNetworkedEntity("Ragdoll")) or ply:InVehicle()) then
		return
	end -- If there's a ragdoll to view through the eyes of or a car to look out of, disable this hook.
	local wep = ply:GetActiveWeapon();
	if (IsValid(wep) and
		(wep:GetClass() == "gmod_tool" or wep:GetClass() == "gmod_camera" or
			wep:GetClass() == "weapon_physgun" or (wep.dt and wep.dt.ironsights))) then
		return;
	end
	local view = {origin = origin, angles = angles, fov = fov};
	if ply:IsOnGround() and
		(ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVERIGHT) or
			ply:KeyDown(IN_MOVELEFT)) then
		-- Is the player running?
		if (ply:GetVelocity():Length() > MS.Config["Run Speed"] - 10) then
			a = a + 10 * FrameTime();
			b = b + 11 * FrameTime();
			view.angles.yaw = view.angles.yaw + math.cos(a) * 0.4;
		else
			a = a + 6 * FrameTime();
			b = b + 7 * FrameTime();
			view.angles.yaw = view.angles.yaw + math.cos(a) * 0.2;
		end
		view.angles.pitch = view.angles.pitch + math.sin(b) * 0.5;
	elseif (ply._Scopin) then
		b = b + FrameTime() * 0.5;
		view.angles.pitch = view.angles.pitch + math.sin(b) * 0.1;
	else
		b = b + FrameTime();
		view.angles.yaw = view.angles.yaw + math.cos(a);
		view.angles.pitch = view.angles.pitch + math.sin(b) * 0.4;
	end
	return view;
end
