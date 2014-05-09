--[[
	~ Serverside Commands Library ~
	~ Applejack ~
--]]

GM.Commands = {};

--[[
GM:RegisterCommand{
	Command   = "whatever";
	Access    = "a";
	Arguments = "<thing> <bees|what|dix> [meh]";
	Types     = "Player Phrase ...";
	Category  = "Stuff";
	Help      = "I don't really care tbh";
	Hidden    = false;
	Function  = function(ply, thing, otherthing, words)
		return false, "GO AWAY!";
	end
};
--]]
local Types = {
	["string"] = true; -- Do nothing
	["number"] = true; -- tonumber(arg) or error
	["bool"]   = true; -- tobool(arg);
	["player"] = true; -- player.Get(arg) or error
	["phrase"] = true; -- phrases[arg] or error
	["..."]    = true; -- Every remaining argument is combined into a string seperated by spaces.
};

---
-- Registers a new command. <br />
-- Usage:
-- <pre>
-- GM:RegisterCommand{
--    Command   = "whatever";
--    Access    = "a";
--    Arguments = "<thing> <bees|what|dix> [meh]";
--    Types     = "Player Phrase ...";
--    Category  = "Stuff";
--    Help      = "I don't really care tbh";
--    Hidden    = false;
--    Function  = function(ply, thing, otherthing, words)
--        return false, "GO AWAY!";
--    end
-- };
-- </pre>
-- If a command is hidden, it won't show up in the help and it won't be runnable from chat. <br />
-- Note that arguments must be surrounded by <>s or []s. <> arguments are required while [] arguments may be left blank if so desired. <br />
-- Types can be String, Bool, Number, Player, Phrase or ... <br />
-- Arguments will be converted to the specified types before being passed to your callback. <br />
-- Phrase arguments require that the user enter one of the words given in the argument string. Seperate phrases with |s as so: <one|two|three>. Do not put spaces in the phrases unless you intend the user to enter them. <br />
-- Try to keep your commands as simple as possible. The average person is unlikely to remember more than two arguments at best. Consider using menus for anything even remotely complicated.
-- @param tab The command table. See above
function GM:RegisterCommand(tab)
	-- Catch various shit not defined
	if (not tab.Command) then
		error("Command not defined!", 2);
	end
	tab.Function = tab.Function or tab[1] or error("Function not defined!", 2);
	if (not tab.Access) then
		tab.Access = self.Config["Base Access"];
	end
	if (not tab.Hidden) then
		if (not tab.Category) then
			if (tab.Access == "s") then
				tab.Category = "Superadmin Commands";
			elseif (tab.Access == "a") then
				tab.Category = "Admin commands";
			elseif (tab.Access == "m") then
				tab.Category = "Moderator Commands";
			else
				tab.Category = "Commands";
			end
		end
		if (not tab.Help) then
			tab.Help = "No help specified.";
		end
	end
	if (not tab.Arguments or tab.Arguments == "") then
		tab.Arguments = ""
		tab.targs = 0;
		tab.rargs = 0;
		tab.oargs = 0;
	else
		-- First, explode the types
		local types = {};
		for kind in string.gmatch(tab.Types, "[^%s]+") do
			types[#types+1] = string.lower(kind);
		end
		-- Now explode the argument strings
		local req, opt, tot = 0, 0, 0;
		local args = {};
		local kind;
		for mode, name in string.gmatch(tab.Arguments, "([[<])(.-)[%]>]") do
			if (mode == "<") then
				req = req + 1;
				-- Catch a potential fuckup
				if (opt ~= 0) then
					error("Malformed argument string! You can only have optional arguments at the end of the call.", 2);
					-- If you've come here wondering what this means, you have put a required argument after an optional argument
					--  This is a logical error and while I could potentially automatically fix it, that might cause probelms with
					--  your internal logic. Better to design right in the first place, no? :o)
				end
			elseif (mode == "[") then
				opt = opt + 1;
			end
			tot = tot + 1;
			args[tot] = name;
			kind = types[tot];
			if (not kind) then
				error("There are more Arguments than Types!", 2);
			end
			if (kind == "...") then
				-- Vararg endings overrule anything else
				tab.VarArg = tot;
				break;
			elseif (kind == "phrase") then
				tab.Phrases = tab.Phrases or {};
				local ps = {};
				for match in string.gmatch(name .. "|", "%s*(.-)%s*|") do
					ps[string.lower(match)] = true;
				end
				tab.Phrases[tot] = ps;
			elseif (not Types[kind]) then
				error("Unknown Type '" .. kind .. "'!", 2);
			end
		end
		tab.Types = types;
		tab.aargs = args;
		tab.rargs = req;
		tab.oargs = opt;
		tab.targs = tot;
	end
	self.Commands[tab.Command] = tab;
	if (tab.Hidden) then
		return;
	end
	-- Standin
	local args = tab.Arguments;
	if (args ~= '') then
		args = args .. ' ';
	end
	cider.help.add(tab.Category, self.Config["Command Prefix"] .. tab.Command .. ' ' .. args .. '- ' .. tab.Help);
	-- TODO: Setup help files and send to client.
end

function GM:ParseCommand(ply, text)
	local args = {};
	local varg      = 0;
	local j         = 1;
	local leng      = text:len();
	local lastc     = '';
	local quoting   = false;
	local c         = 1;
	local i         = 1;
	local ctext     = "";
	while (i <= leng) do
		ctext = text:sub(i, i);
		if (i == leng) then
			args[#args+1] = text:sub(j);
			break;
		elseif (quoting) then
			if (ctext == ' ' and lastc == '"') then
				quoting = false;
				args[#args+1] = text:sub(j, i-2);
				c = c + 1;
				j = i + 1;
			end
		else
			if (ctext == ' ') then
				args[#args+1] = text:sub(j, i-1);
				-- This is the first argument, and thus is the command.
				if (c == 1) then
					local cmd = self.Commands[args[1]];
					-- Make sure it exists so we don't do evreything for nothing
					if (not cmd) then
						-- Skip everything else, so the command handler can yell at them.
						break;
					end
					--  Apply vargocity
					if (cmd.VarArg) then
						varg = cmd.VarArg + 1;
					end
				end
				c = c + 1;
				j = i + 1
			elseif (ctext == '"' and lastc == ' ') then
				quoting = true;
				j = i + 1;
			end
		end
		lastc = ctext;
		i = i + 1;
		if (c == varg) then
			args[#args+1] = text:sub(i);
			break;
		end
	end
	self:DoCommand(ply, args);
end

function GM:PlayerSay(ply, text, public)
	-- The OOC commands have shortcuts.
	if (string.sub(text, 1, 2) == "//") then
		text = string.Trim(string.sub(text, 3));
		if (text == "") then
			return "";
		end
		text = self.Config['Command Prefix'] .. "ooc " .. text;
	elseif (string.sub(text, 1, 3) == ".//") then
		text = string.Trim(string.sub(text, 4));
		if (text == "") then
			return "";
		end
		text = self.Config['Command Prefix'] .. "looc " .. text;
	end

	-- Commands
	if (string.sub(text, 1, 1) == self.Config["Command Prefix"]) then
		-- Get rid of the prefix
		text = string.Trim(string.sub(text, 2));
		self:ParseCommand(ply, text);
	elseif (gamemode.Call("PlayerCanSayIC", ply, text)) then
		if (ply:Arrested()) then
			cider.chatBox.addInRadius(ply, "arrested", text, ply:GetPos(), self.Config["Talk Radius"])
		elseif ply:Tied() then
			cider.chatBox.addInRadius(ply, "tied", text, ply:GetPos(), self.Config["Talk Radius"])
		else
			cider.chatBox.addInRadius(ply, "ic", text, ply:GetPos(), self.Config["Talk Radius"])
		end
		GM:Log(EVENT_TALKING,"%s: %s",ply:Name(),text)
	end
	return "";
end

function GM:DoCommand(ply, args)
	if (not ply._Initialized) then
		return;
	end
	if (not args[1]) then
		ply:Notify("You're doing it wrong!", NOTIFY_ERROR);
		return;
	end
	local str = string.lower(table.remove(args, 1));
	local cmd = self.Commands[str];
	-- Existence test
	if (not cmd) then
		ply:Notify("Unknown command '" .. str .. "'!", NOTIFY_ERROR);
		return;
	end
	-- Hook test
	if (not gamemode.Call("PlayerCanUseCommand", ply, str, args, cmd)) then
		return;
	end
	-- Access test
	if (not ply:HasAccess(cmd.Access)) then
		ply:Notify("You do not have the required access to use that command!", NOTIFY_ERROR);
		return;
	end
	-- Numargs test
	local nargs = #args;
	if (nargs < cmd.rargs) then
		ply:Notify("Not enough arguments specified!", NOTIFY_ERROR);
		ply:Notify("Usage: " .. self.Config["Command Prefix"] .. cmd.Command .. " " .. cmd.Arguments, NOTIFY_CHAT);
		return;
	end
	--Parse t' args
	local pargs = {};
	if (cmd.targs > 0) then
		local t, arg;
		for i = 1, cmd.targs do
			arg = args[i];
			if (not arg) then
				-- I'm assuming all the required args are done by here. Something's gone wrong if they're not.
				break;
			end
			arg = string.Trim(arg);
			if (arg == "") then
				ply:Notify("Don't force blank arguments please.", NOTIFY_ERROR);
				return;
			end
			t = cmd.Types[i];
			if (t == "string") then
				pargs[i] = arg;
			elseif (t == "bool") then
				pargs[i] = tobool(arg);
			elseif (t == "number") then
				local n = tonumber(arg);
				if (not n) then
					ply:Notify("Invalid number for argument #" .. i .. ": " .. cmd.aargs[i] .. "!", NOTIFY_ERROR);
					ply:Notify("Usage: " .. self.Config["Command Prefix"] .. cmd.Command .. " " .. cmd.Arguments, NOTIFY_CHAT);
					return;
				end
				pargs[i] = n;
			elseif (t == "player") then
				local pl = player.Get(arg);
				if (not pl) then
					ply:Notify("Cannot find player '" .. arg .. "' for argument #" .. i .. ": " .. cmd.aargs[i] .. "!", NOTIFY_ERROR);
					ply:Notify("Usage: " .. self.Config["Command Prefix"] .. cmd.Command .. " " .. cmd.Arguments, NOTIFY_CHAT);
					return;
				end
				pargs[i] = pl;
			elseif (t == "phrase") then
				local w = string.lower(arg);
				if (not cmd.Phrases[i][w]) then
					ply:Notify("'" .. w .. "' is not a valid choice for argument #" .. i .. ": " .. cmd.aargs[i] .. "!", NOTIFY_ERROR);
					ply:Notify("Usage: " .. self.Config["Command Prefix"] .. cmd.Command .. " " .. cmd.Arguments, NOTIFY_CHAT);
					return;
				end
				pargs[i] = w;
			elseif (t == "...") then
				-- There is no way that this should be able to be *all* whitespace, so I won't check if it's empty.
				pargs[i] = string.Trim(table.concat(args, " ", i));
				break;
			end
		end
	end
	local stat, res, err = pcall(cmd.Function, ply, unpack(pargs));
	for k, v in pairs(pargs) do
		pargs[k] = tostring(v);
	end
	if (not stat) then
		Error("[", os.date(), "] Moonshine: Command '", cmd.Command, ' "', table.concat(pargs, '" "'), "\" 's callback failed: ", res, "\n");
	elseif (res == false) then
		if (err and err ~= "") then
			ply:Notify(err, NOTIFY_ERROR);
		end
		return;
	end
	local words = table.concat(pargs, '" "');
	if (words ~= "") then
		words = ' "' .. words .. '"';
	end
	GM:Log(EVENT_COMMAND, "%s ran the command %s%s", ply:Name(), cmd.Command, words);
end

concommand.Add("mshine", function(ply, _, _, command)
	GM:ParseCommand(ply, command);
end);
