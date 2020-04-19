--
-- "sh_laws.lua"
-- ~ Applejack ~
--
cider.laws = {};
cider.laws.stored = {
	"No Running",
	"No Throwing",
	"No Pushing",
	"No Shouting",
	"No Jumping",
	"No Splashing",
	"No Bombing",
	"No Ducking",
	"No Petting",
	"No Armbands Beyond This Point", -- I love how surreal this is, but no one ever comments on it. *SIGH*
}

---
--- Reads the laws from a net message
--- @return boolean
function cider.laws.recieve()
	local updated = false
	for i = 1, 10 do
		local law = net.ReadString();
		if cider.laws.stored[i] ~= law then
			updated = true
			cider.laws.stored[i] = law
		end
	end
	return updated;
end

if SERVER then
	util.AddNetworkString("cider_Laws");

	function cider.laws.send(recipient)
		net.Start("cider_Laws")
		for i = 1, 10 do
			net.WriteString(cider.laws.stored[i]);
		end
		if (recipient) then
			net.Send(recipient);
		else
			net.Broadcast();
		end
	end

	local function updateLaws(len, ply)
		ply._NextLawUpdate = ply._NextLawUpdate or CurTime()
		if ply._NextLawUpdate > CurTime() then
			ply:Notify(
				"You must wait another " ..
					string.ToMinutesSeconds(ply._NextLawUpdate - CurTime()) ..
					" minute(s) to update the laws!", 1
			)
			return
		end

		ply._NextLawUpdate = CurTime() + 120
		if not hook.Call("PlayerCanChangeLaws", GAMEMODE, ply) then
			ply:Notify("You may not change the laws.", 1)
			return
		end

		local updated = cider.laws.recieve()
		if updated then
			cider.laws.send()
			player.NotifyAll(
				NOTIFY_GENERIC, "%s just updated the city laws", ply:GetName()
			)
		end
	end
	net.Receive("cider_Laws", updateLaws)
else
	cider.laws.update = true

	net.Receive(
		"cider_Laws", function(len)
			cider.laws.update = cider.laws.recieve();
		end
	)
end
