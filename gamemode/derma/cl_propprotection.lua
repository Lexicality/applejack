--[[
    ~ Clientside Prop Protection ~
	~ Applejack ~
--]]

local cPanel, aPanel;


local function adminPanel(panel)
    panel:ClearControls();

    -- Thou shalt remember me
    aPanel = panel;

    -- Only admins admin. 
    if (not lpl:IsAdmin()) then
        panel:Help("You're not an admin!");
        return;
    end
    -- Otherwise, let's get started
    panel:Help("Applejack - Prop Protection - Admin Controls");

    -- Superadmin settings
    if (lpl:IsSuperAdmin()) then

        -- Deal with our secret cvars.
        do
            -- Note to self: Remember to update these if you change the serverside confif (ha ha ha)
            local config = {
                enabled = 1;
                cleanup = 1;
                delay = 120;
            }
            local function serverCallback(cvar, _, new)
                RunConsoleCommand("_" .. cvar, new);
            end
            local function clientCallback(cvar, prev, new)
                local var = string.match(cvar, "ms_ppconfig_(.+)");
                if (var and config[var]) then
                    local num = tonumber(new);
                    if (num) then
                        config[var] = num;
                    end
                else
                    ErrorNoHalt("Just got an unknown change callback from ", cvar, " changing to '", new, "' from '", prev, "'!\n")
                end
            end
            for key in pairs(config) do
                local cvar = "ms_ppconfig_" .. key;
                -- Get the convar values from the server
                if (ConVarExists(cvar)) then
                    config[key] = GetConVarNumber(cvar);
                    cvars.AddChangeCallback(cvar, serverCallback);
                else
                    -- I'm not 100% sure what to do here. D:
                    ErrorNoHalt("Could not find convar ", cvar, " for prop protection config!\n");
                end
                -- Create the dummy client convars for the panel
                CreateClientConVar("_" .. cvar, config[key], false, false);
                cvars.AddChangeCallback("_" .. cvar, clientCallback);
            end

            concommand.Add("_ms_ppconfig", function()
                if (not lpl:IsSuperAdmin()) then return; end
                -- Oh hey. A legitimate use for datastream!
                datastream.StreamToServer("ppconfig", config);
            end);
        end
        -- That mess out of the way, let's do the settings panel

        panel:Help(" ");
        panel:Help("Settings");
        panel:Checkbox("Active", "_ms_ppconfig_enabled");
        panel:CheckBox("Disconnection Cleanup", "_ms_ppconfig_cleanup");
        panel:NumSlider("Cleanup Delay", "_ms_ppconfig_delay", 10, 300, 0);
        panel:Button("Apply Settings", "_ms_ppconfig");
    end
    -- And on with the main show.

    panel:Help(" ");
    panel:Help("Prop Cleanup");
    for _, ply in pairs(player.GetAll()) do
        if (IsValid(ply)) then
            -- Ick
            panel:Button(ply:Name(), "cider", "ppclearprops", ply:UniqueID());
        end
    end
    panel:Help(" ");
    panel:Button("All Disconnected Players", "cider", "ppcleardisconnected");
    -- TODO: Make this exist
    --panel:Button("Everyone", "cider", "ppcleareveryone");
end

function clientPanel(panel)
    panel:ClearControls();

    cPanel = panel;

    panel:Help("Applejack - Prop Protection");
    panel:Help(" ");
    panel:Button("Cleanup my props", "cider", "ppcleanprops");
    panel:Help(" ");
    panel:Help("Buddies");
    -- TODO: Classy spreadsheet action
end

local function SpawnMenuOpen()
    if (aPanel) then
        adminPanel(aPanel);
        hook.Remove("SpawnMenuOpen", "Post Init Spawnmenu Rebuild");
    end
end
local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Prop Protection", "Admin",  "Admin",  "", "", adminPanel );
	spawnmenu.AddToolMenuOption("Utilities", "Prop Protection", "Client", "Client", "", "", clientPanel);
end
hook.Add("SpawnMenuOpen", "PP Post Init Spawnmenu Rebuild", SpawnMenuOpen);
hook.Add("PopulateToolMenu", "Applejack Prop Protection Population", PopulateToolMenu);
