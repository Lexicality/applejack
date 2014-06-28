--[[
Name: "sh_help.lua".
	~ Applejack ~
--]]

cider.help = {};
cider.help.stored = {};

function cider.help.add(cat, help)
	cider.help.stored[cat] = cider.help.stored[cat] or {};
	table.insert(cider.help.stored[cat], help);
	if (CLIENT and cider.menu and cider.menu.tabs["Help"]) then
		cider.menu.tabs["Help"]:Reload();
	end
end
if (CLIENT) then
	net.Receive("Moonshine Help", function()
		local data = {};
		for i = 1, net.ReadUInt(8) do
			local lines = {};
			for i = 1, net.ReadUInt(10) do
				lines[i] = net.ReadString();
			end
			data[net.ReadString()] = lines;
		end
		cider.help.stored = data;
		if (cider.menu and cider.menu.tabs["Help"]) then
			cider.menu.tabs["Help"]:Reload();
		end
	end);
else
	--[[ Add generic helps TODO: Do bettr ]]--
	cider.help.add("General", "Using any exploits will get you banned permanently.");
	cider.help.add("General", "Put // before your message to talk in global OOC.");
	cider.help.add("General", "Put .// before your message to talk in local OOC.");
	cider.help.add("General", "Press F1 to open the main menu.");
	cider.help.add("General", "Press F2 to open the access menu when looking at something you have access to.");

	util.AddNetworkString("Moonshine Help");
	hook.Add("PlayerInitialized", "Applejack Help Spammer", function(ply)
		local help = cider.help.stored;
		net.Start("Moonshine Help");
		net.WriteUInt(table.Count(help), 8)
		for key, lines in pairs(help) do
			net.WriteUInt(#lines, 10);
			for _, line in ipairs(lines) do
				net.WriteString(line);
			end
			net.WriteString(key);
		end
		net.Send(ply);
	end);
end
