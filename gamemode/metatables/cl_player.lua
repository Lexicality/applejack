--
-- ~ Clientside Player metatable ~
-- ~ Applejack ~
--
local meta = _R.Player;
if (not meta) then
	error(
		"[" .. os.date() ..
			"] Applejack Clientside Player metatable: No metatable found!"
	);
end

function meta:ESPPaint(lines, pos, dist, centre, ragdoll)
	if (self:GetColor() == 0 or self:GetRagdollEntity():IsValid() and not ragdoll) then
		return;
	end
	lines:Add("Name", self:Name(), team.GetColor(self:Team()), 1);
	if (self:GetNWBool("Typing")) then
		lines:Add("Typing", "(Typing)", color_white, 2);
	end
	if (not self:Alive()) then
		lines:Add("Status", "(Dead)", color_lightgray, 3);
	elseif (self:Tied()) then
		lines:Add("Status", "(Tied)", color_lightblue, 3);
	end
	local details = self:GetNWString("Details");
	if (details ~= "") then
		lines:Add("Details", "Details: " .. details, color_white, 5);
	end
	if (not centre) then
		return;
	end

	local clan = self:GetNWString("Clan");
	if (clan ~= "") then
		lines:Add("Clan", "Clan: " .. clan, color_white, 6);
	end
	lines:Add("Job", "Job: " .. self:GetNWString("Job"), color_white, 7);
end
