--
-- ~ Clientside Prop Protection ~
-- ~ Applejack ~
--
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
			local config = {enabled = 1, cleanup = 1, delay = 120}
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
					ErrorNoHalt(
						"Just got an unknown change callback from ", cvar, " changing to '", new,
						"' from '", prev, "'!\n"
					)
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
					ErrorNoHalt(
						"Could not find convar ", cvar, " for prop protection config!\n"
					);
				end
				-- Create the dummy client convars for the panel
				CreateClientConVar("_" .. cvar, config[key], false, false);
				cvars.AddChangeCallback("_" .. cvar, clientCallback);
			end

			concommand.Add(
				"_ms_ppconfig", function()
					if (not lpl:IsSuperAdmin()) then
						return;
					end
					-- Oh hey. A legitimate use for datastream!
					datastream.StreamToServer("ppconfig", config);
				end
			);
		end
		-- That mess out of the way, let's do the settings panel

		panel:Help(" ");
		panel:Help("Settings");
		panel:CheckBox("Active", "_ms_ppconfig_enabled");
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
			panel:Button(ply:Name(), "mshine", "ppclearprops", ply:UniqueID());
		end
	end
	panel:Help(" ");
	panel:Button("All Disconnected Players", "mshine", "ppcleardisconnected");
	-- TODO: Make this exist
	-- panel:Button("Everyone", "mshine", "ppcleareveryone");
end

local lView;
local addButton, delButton, clrButton;

do -- Add
	function addButton()
		local menu = DermaMenu();
		-- I HATE YOU FOR THIS GARRYYYYYYYYYYYYY Give DMenus varargs
		-- TODO: Make the player picker for the access menu a standard thing for everything!
		menu:AddOption("Cancel");
		for _, ply in pairs(player.GetAll()) do
			if (ply ~= lpl) then
				menu:AddOption(
					ply:Name(), function()
						RunConsoleCommand("mshine", "ppfriends", "add", ply:UniqueID());
					end
				)
			end
		end
		menu:Open();
	end
end

do -- Remove
	local function si()
		local line = lView:GetSelectedLine();
		if (not line) then
			return;
		end
		RunConsoleCommand("mshine", "ppfriends", "remove", line:GetColumnText(2));
	end
	function delButton()
		if (not lView:GetSelectedLine()) then
			return;
		end
		local menu = DermaMenu();
		menu:AddOption("Cancel");
		menu:AddOption("Confirm", si);
		menu:Open();
	end
end

do -- Clear
	local function si()
		RunConsoleCommand("mshine", "ppfriends", "clear");
	end
	function clrButton()
		local m = DermaMenu();
		m:AddOption("Cancel");
		m:AddOption("Confirm", si);
		m:Open();
	end
end

local function clientPanel(panel)
	panel:ClearControls();

	cPanel = panel;

	panel:Help("Applejack - Prop Protection");
	panel:Help(" ");
	panel:Button("Delete my props", "mshine", "ppclearprops");
	panel:Help(" ");
	panel:Help("Friends");
	panel:Button("Add Friend").DoClick = addButton;
	local view = vgui.Create("DListView", self);
	lView = view;
	view:SetMultiSelect(false);
	panel:AddPanel(view);
	view:AddColumn("Name");
	view:AddColumn("UniqueID");
	-- view:SetTall(10);
	panel:Button("Remove Friend").DoClick = delButton;
	panel:Button("Clear Friends").DoClick = clrButton;
end

usermessage.Hook(
	"MS PPUpdate", function(msg)
		local action = msg:ReadChar();
		if (action == 1) then
			-- Add
			lView:AddRow(msg:ReadString(), msg:ReadLong());
		elseif (action == 2) then
			-- Remove
			local uid = msg:ReadLong();
			local liens = lView:GetLines();
			for lineID, line in pairs(lView:GetLines()) do
				-- | Name | UID |
				if (tonumber(line:GetColumnText(2)) == uid) then
					lView:RemoveLine(lineID);
					return;
				end
			end
		elseif (action == 3) then
			-- Clear
			lView:Clear();
		elseif (action == 0) then
			-- FUN TIME
			local count;
			-- Online people
			count = msg:ReadShort();
			if (count > 0) then
				local ply;
				for i = 1, count do
					ply = msg:ReadEntity();
					if (ply:IsValid()) then
						lView:AddLine(ply:Name(), ply:UniqueID());
					end
				end
			end
			-- Offline people
			count = msg:ReadShort();
			if (count > 0) then
				for i = 1, count do
					lView:AddLine(msg:ReadString(), msg:ReadLong());
				end
			end
		end
	end
)

----------
-- Hoox --
----------

local dun;
local function SpawnMenuOpen()
	if (dun) then
		error("wat");
	end
	if (aPanel) then
		adminPanel(aPanel);
		hook.Remove("SpawnMenuOpen", "PP Post Init Spawnmenu Rebuild");
		dun = true;
	end
end
local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption(
		"Utilities", "Prop Protection", "Admin", "Admin", "", "", adminPanel
	);
	spawnmenu.AddToolMenuOption(
		"Utilities", "Prop Protection", "Client", "Client", "", "", clientPanel
	);
end
hook.Add("SpawnMenuOpen", "PP Post Init Spawnmenu Rebuild", SpawnMenuOpen);
hook.Add(
	"PopulateToolMenu", "Applejack Prop Protection Population", PopulateToolMenu
);
