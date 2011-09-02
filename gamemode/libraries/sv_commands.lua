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

function GM:RegisterCommand(tab)
    -- Catch various shit not defined
    if (not tab.Command) then
        error("Command not defined!", 2);
    elseif (not tab.Function) then
        error("Function not defined!", 2);
    end
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
        tab.targs    = 0;
    else
        -- First, explode the types
        local types = {};
        for kind in pairs(tab.Types) do
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
                    --[[
                        If you're reading this because you've triggered this error and are confused, here's why it's there.
                        Optional arguments should only ever be at the end of the command, both due to sanity and how this
                         system is coded. You should generally only have one optional argument anyway - If you're using more than
                         two you really should look at how much you're trying to jam into a single command.
                        Perhaps you should split the command up into several commands, one for each option.
                        If you are making this for users, remember that the average person is a complete moron when it comes to
                         typing commands into the chatbox and is unlikely to remember any syntax longer than two arguments.
                        Keep your commands simple and use menus as much as possible.
                        ~Lex
                    --]]
                    -- TODO: Saneify this lecture into a proper docstring and shove it at the top of the function. ;)
                    error("Malformed argument string! You can only have optional arguments at the end of the call.", 2);
                    -- If you've come here wondering what this means, you have put a required argument after an optional argument
                    --  This is a logical error and while I could potentially automatically fix it, that might cause probelms with
                    --  your internal logic. Better to design right in the first place, no? :o)
            elseif (mode == "[") then
                opt = opt + 1;
            end
            args[tot] = name;
            tot = tot + 1;
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
                for match in string.gmatch(name .. "|", "(.-)|") do
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
    -- TODO: Setup help files and send to client.
end







cider.command = {};
cider.command.stored = {};

-- Add a new command.
function cider.command.add(command, access, arguments, callback, category, help, tip, unpack)
	cider.command.stored[command] = {access = access, arguments = arguments, callback = callback, unpack = tobool(unpack)};
	
	-- Check to see if a category was specified.
	if (category) then
		if (!help or help == "") then
			cider.help.add(category, GM.Config["Command Prefix"]..command.." <none>.", tip);
		else
			cider.help.add(category, GM.Config["Command Prefix"]..command.." "..help..".", tip);
		end
	end
end

-- This is called when a player runs a command from the console.
function cider.command.consoleCommand(player, _, arguments)
	if not (player._Initialized) then return end
	if (arguments and arguments[1]) then
		command = string.lower(table.remove(arguments, 1));
		-- Check to see if the command exists.
		if (cider.command.stored[command]) then
			-- Loop through the arguments and fix Valve's errors.
			for k, v in pairs(arguments) do
				arguments[k] = string.Replace(arguments[k], " ' ", "'");
				arguments[k] = string.Replace(arguments[k], " : ", ":");
			end
			
			-- Check if the player can use this command.
			if ( hook.Call("PlayerCanUseCommand", GAMEMODE, player, command, arguments) ) then
				if (#arguments >= cider.command.stored[command].arguments) then
					if (player:HasAccess(cider.command.stored[command].access) ) then
						-- Some callbacks remove arguments from the table, and we don't want to lose them ;)
						local success, fail,msg
						if cider.command.stored[command].unpack then
							success, fail,msg = pcall(cider.command.stored[command].callback, player, unpack(arguments));
						else
							success, fail,msg = pcall(cider.command.stored[command].callback, player, table.Copy(arguments));
						end
						if success then
							if fail ~= false then
								local text = ""
								if (table.concat(arguments, " ") ~= "") then
									text = text.." "..table.concat(arguments, " ")
								end
								GM:Log(EVENT_COMMAND,"%s used 'cider %s%s'.",player:Name(),command,text);
							else
								if msg and msg ~= "" then
									player:Notify(msg,1)
								end
							end
						else
							ErrorNoHalt(os.date().." callback for 'cider "..command.." "..table.concat(arguments," ").."' failed: "..fail.."\n")
						end
					else
						player:Notify("You do not have access to this command, "..player:Name()..".", 1);
					end
				else
					player:Notify("This command requires "..cider.command.stored[command].arguments.." arguments!", 1);
				end
			end
		else
			player:Notify("This is not a valid command!", 1);
		end
	else
		player:Notify("This is not a valid command!", 1);
	end
end

-- Add a new console command.
concommand.Add("cider", cider.command.consoleCommand);
