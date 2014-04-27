--[[
Name: "sh_help.lua".
	~ Applejack ~
--]]

cider.help = {};
cider.help.stored = {};

function cider.help.add(cat, help, tip)
	cider.help.stored[cat] = cider.help.stored[cat] or {};
	table.insert(cider.help.stored[cat],{ text = help, tip = tip});
	if (CLIENT and cider.help.panel) then
		cider.help.panel:Reload();
	end
end
if (CLIENT) then
	datastream.Hook("helpReplace",function(_,_,_,data)
		cider.help.stored = data;
		if (cider.help.panel) then
			cider.help.panel:Reload();
		end
	end);
else
	--[[ Add generic helps TODO: Do bettr ]]--
	cider.help.add("General", "Using any exploits will get you banned permanently.");
	cider.help.add("General", "Put // before your message to talk in global OOC.");
	cider.help.add("General", "Put .// before your message to talk in local OOC.");
	cider.help.add("General", "Press F1 to open the main menu.");
	cider.help.add("General", "Press F2 to open the access menu when looking at something you have access to.");
	hook.Add("PlayerInitialized","Applejack Help Spammer", function(ply)
		datastream.StreamToClients(ply,"helpReplace",cider.help.stored);
	end);
end
