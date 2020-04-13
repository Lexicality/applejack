--
-- ~ Help "Library" ~
-- ~ Moonshine ~
--
GM.HelpItems = {};

function GM:AddHelp(cat, help)
	self.HelpItems[cat] = self.HelpItems[cat] or {};
	table.insert(self.HelpItems[cat], help);
	if (CLIENT and cider.menu and cider.menu.tabs["Help"]) then
		cider.menu.tabs["Help"]:Reload();
	end
end
if (CLIENT) then
	net.Receive(
		"Moonshine Help", function()
			local data = {};
			for i = 1, net.ReadUInt(8) do
				local lines = {};
				for i = 1, net.ReadUInt(10) do
					lines[i] = net.ReadString();
				end
				data[net.ReadString()] = lines;
			end
			GM.HelpItems = data;
			if (cider.menu and cider.menu.tabs["Help"]) then
				cider.menu.tabs["Help"]:Reload();
			end
		end
	);
else
	-- Add generic helps TODO: Do bettr
	GM:AddHelp("General", "Using any exploits will get you banned permanently.");
	GM:AddHelp("General", "Put // before your message to talk in global OOC.");
	GM:AddHelp("General", "Put .// before your message to talk in local OOC.");
	GM:AddHelp("General", "Press F1 to open the main menu.");
	GM:AddHelp(
		"General",
		"Press F2 to open the access menu when looking at something you have access to."
	);

	util.AddNetworkString("Moonshine Help");
	hook.Add(
		"PlayerInitialized", "Applejack Help Spammer", function(ply)
			local help = GM.HelpItems;
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
		end
	);
end
