--[[
    ~ Clientside Prop Protection ~
	~ Applejack ~
--]]

local cPanel, aPanel;

-- TODO: Find some kind of way of working these names out automagically
local config = {
	enabled = 1;
    cleanup = 1;
	delay = 120;
}
for key in pairs(config) do
    local cvar = "ms_ppconfig_" .. key;
    -- Get the convar values from the server
    if (ConVarExists(cvar)) then
        config[key] = GetConVarNumber(cvar);
    else
        -- I'm not 100% sure what to do here. D:
        ErrorNoHalt("Could not find convar ", cvar, " for prop protection config!\n");
    end
    -- Create the dummy client convars for the panel
    CreateClientConVar("_ms_ppconfig_" .. key, config[key], false, false);
end

local function adminpanel(Panel)
    Panel:ClearControls();

    -- Thou shalt remember me
    aPanel = Panel;

    -- Only admins admin. 
    if (not lpl:IsAdmin()) then
        Panel:AddControl(
            "Label",
            {
                Text = "You're not an admin!";
            });
        return;
    end

    
	
	Panel:AddControl("Label", {Text = "SPP - Admin Panel - Applejack version - Spacetech/Lexi"})
	
	Panel:AddControl("CheckBox", {Label = "Prop Protection", Command = "sppa_check"})
	Panel:AddControl("CheckBox", {Label = "Admins Can Do Everything", Command = "sppa_admin"})
	Panel:AddControl("CheckBox", {Label = "Physgun Reload Protection", Command = "sppa_pgr"})
	Panel:AddControl("CheckBox", {Label = "Admins Can Touch World Prop", Command = "sppa_awp"})	
	Panel:AddControl("CheckBox", {Label = "Disconnect Prop Deletion", Command = "sppa_dpd"})
	Panel:AddControl("CheckBox", {Label = "Delete Admin Entities", Command = "sppa_dae"})
	Panel:AddControl("Slider", {Label = "Deletion Delay (Seconds)", Command = "sppa_delay", Type = "Integer", Min = "10", Max = "500"})
	Panel:AddControl("Button", {Text = "Apply Settings", Command = "sppa_apply"})
	
	Panel:AddControl("Label", {Text = "Cleanup Panel"})
	
	for k, ply in pairs(player.GetAll()) do
		if(ply and ply:IsValid()) then
			Panel:AddControl("Button", {Text = ply:Nick(), Command = "sppa_cleanupprops "..ply:EntIndex()})
		end
	end
	
	Panel:AddControl("Label", {Text = "Other Cleanup Options"})
	Panel:AddControl("Button", {Text = "Cleanup Disconnected Players Props", Command = "sppa_cdp"})
end

function cider.menu.pp.ClientPanel(Panel)
	Panel:ClearControls()
	
	if(!cider.menu.pp.ClientCPanel) then
		cider.menu.pp.ClientCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "SPP - Client Panel - Applejack version - Spacetech/Lexi"})
	
	Panel:AddControl("Button", {Text = "Cleanup Props", Command = "sppa_cleanupprops"})
	Panel:AddControl("Label", {Text = "Friends Panel"})
	
	local Players = player.GetAll()
	if(table.Count(Players) == 1) then
		Panel:AddControl("Label", {Text = "No Other Players Are Online"})
	else
		for k, ply in pairs(Players) do
			if(ply and ply:IsValid() and ply ~= LocalPlayer()) then
				local FriendCommand = "sppa_friend_"..ply:GetNWString("SPPSteamID")
				if(!LocalPlayer():GetInfo(FriendCommand)) then
					CreateClientConVar(FriendCommand, 0, false, true)
				end
				Panel:AddControl("CheckBox", {Label = ply:Nick(), Command = FriendCommand})
			end
		end
		Panel:AddControl("Button", {Text  = "Apply Settings", Command = "sppa_applyfriends"})
	end
	Panel:AddControl("Button", {Text  = "Clear Friends", Command = "sppa_clearfriends"})
end

function cider.menu.pp.SpawnMenuOpen()
	if(cider.menu.pp.AdminCPanel) then
		cider.menu.pp.AdminPanel(cider.menu.pp.AdminCPanel)
	end
	if(cider.menu.pp.ClientCPanel) then
		cider.menu.pp.ClientPanel(cider.menu.pp.ClientCPanel)
	end
end
hook.Add("SpawnMenuOpen", "cider.menu.pp.SpawnMenuOpen", cider.menu.pp.SpawnMenuOpen)

function cider.menu.pp.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection (Applejack)", "Admin", "Admin", "", "", cider.menu.pp.AdminPanel)
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection (Applejack)", "Client", "Client", "", "", cider.menu.pp.ClientPanel)
end
hook.Add("PopulateToolMenu", "cider.menu.pp.PopulateToolMenu", cider.menu.pp.PopulateToolMenu)
