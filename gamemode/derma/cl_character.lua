--
-- "cl_character.lua"
-- ~ Applejack ~
--
local PANEL = {};
local nextChanges = {};
local reDraw = false;
local function redraw()
	reDraw = true;
end
local function teamChanged(msg)
	local teamid = msg:ReadChar();
	nextChanges[teamid] = team.Query(teamid, "Cooldown", 300) + CurTime();
	timer.Simple(0.1, redraw);
end
usermessage.Hook("TeamChange", teamChanged);

local function cmd(cmd, ...)
	RunConsoleCommand("mshine", cmd, ...);
end

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cider.menu.width, cider.menu.height - 8);
	-- Create a panel list to store the items.
	self.itemsList = vgui.Create("DPanelList", self);
	self.itemsList:SizeToContents();
	self.itemsList:SetPadding(2);
	self.itemsList:SetSpacing(3);
	self.itemsList:StretchToParent(4, 4, 12, 44);
	self.itemsList:EnableVerticalScrollbar();
	-- We'll do the rest in the think func
	reDraw = true
	-- TODO: Find out why this sometimes isn't there
	if not lpl._ModelChoices then
		lpl._ModelChoices = {}
		for id, team in pairs(GM.Teams) do
			for gender,models in pairs(team.Models) do
				lpl._ModelChoices[gender] = lpl._ModelChoices[gender] or {}
				if #models ~= 1 then
					lpl._ModelChoices[gender][id] = math.random(1,#models)
				else
					lpl._ModelChoices[gender][id] = 1
				end
			end
		end
	end
end

local thinktest = CurTime()
function PANEL:Think()
	if not reDraw then return; end
	reDraw = false
	local pteam = lpl:Team();
	local lgroup = team.Query(pteam, "Group");
	--Wipe the itemlist so we can renew it
	self.itemsList:Clear()

	local header = vgui.Create("DCollapsibleCategory", self);
	header:SetLabel("Character Details");
	local contents = vgui.Create("DPanel");
	function contents:PerformLayout()
		self:SizeToChildren(false, true);
	end
	contents:DockPadding(5, 3, 5, 3);
	contents:InvalidateLayout();

	local job, clan, details, gender;
	-- Create the job control.
	job = vgui.Create("cider_Character_TextEntry", contents);
	job:SetCommand("job");
	job:SetLabel("Job Title");
	job:Dock(TOP)

	-- Create the clan control.
	clan = vgui.Create("cider_Character_TextEntry", contents);
	clan:SetCommand("clan");
	clan:SetLabel("Clan");
	clan:Dock(TOP)

	-- Create the details control.
	details = vgui.Create("cider_Character_TextEntry", contents);
	details:SetLabel("Details");
	details:SetCommand("details");
	details:SetValue(lpl:GetNWString("Details") or "")
	details:Dock(TOP)

	-- Create the gender control.
	gender = vgui.Create("cider_Character_Gender", contents);
	gender:Dock(TOP)

	header:SetContents(contents);

	self.job, self.clan, self.details, self.gender = job, clan, details, gender;
	self.userDetails = header;
	self.itemsList:AddItem(header);
	-- self.itemsList:AddItem(contents);

	local subitemsList;
	-- Loop through each of our groups in numerical order
	for _, group in pairs(GM.Groups) do
		if (group.Invisible) then continue; end
		header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(cider.menu.width, 50); -- Keep the second number at 50
		header:SetLabel( group.Name )
		header:SetExpanded(lgroup == group)
		header:SetToolTip( group.Description )
		self.itemsList:AddItem(header);
		subitemsList = vgui.Create("DPanelList", self);
		subitemsList:SetAutoSize( true )
		subitemsList:SetPadding(2);
		subitemsList:SetSpacing(3);
		header:SetContents( subitemsList )
		header.ilist = subitemsList
		-- Store the list of teams here sorted by their index.
		local teams = {};

		-- Loop through the teams in this group in order
		for _, team in ipairs(group.Teams) do
			--Check they can join the team
			if (pteam == team.TeamID or gamemode.Call("PlayerCanJoinTeamShared", lpl, team.TeamID)) then
				-- Create the team panel.
				local panel = vgui.Create("cider_Character_Team", self);
				panel:SetTeam(team);
				-- Add the controls to the item list.
				subitemsList:AddItem(panel);
			end
		end
	end
	self.itemsList:Rebuild();
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end

-- Register the panel.
vgui.Register("cider_Character", PANEL, "Panel");

-- cider_Character_Editor
local PANEL = {};

AccessorFunc(PANEL, "m_Command", "Command");

function PANEL:Init()
	self:SetSizeX(false);
	self:DockPadding(0, 2, 0, 2);
	self:InvalidateLayout();

	local label, button;

	label = vgui.Create("DLabel", self);
	label:SetContentAlignment( 6 );
	-- label:SetAutoStretchVertical( true );
	label:SetDark(true);
	label:Dock(LEFT);

	button = vgui.Create("DButton", self);
	button:SetText("Change");
	button:Dock(RIGHT);
	button.DoClick = function()
		self:ButtonPress();
	end

	self.label, self.button = label, button;
end

function PANEL:SetContents(panel)
	panel:SetParent(self);
	panel:Dock(FILL);
	panel:DockMargin( 8, 0, 8, 0 );
	self.contents = panel;
	self:InvalidateLayout();
end

function PANEL:SetLabel(text)
	self.label:SetText(text)
end

function PANEL:ButtonPress()
end

function PANEL:Command(...)
	cmd(self:GetCommand(), ...);
end

vgui.Register("cider_Character_Editor", PANEL, "DSizeToContents");

-- cider_Character_TextEntry
local PANEL = {};

function PANEL:Init()
	local contents = vgui.Create("DTextEntry", self);
	contents:SetContentAlignment(5);
	self:SetContents(contents);
end

function PANEL:SetValue(text)
	self.contents:SetValue(text);
end

function PANEL:ButtonPress()
	self:Command(self.contents:GetValue());
end

vgui.Register("cider_Character_TextEntry", PANEL, "cider_Character_Editor");

-- cider_Character_Gender
local PANEL = {};

function PANEL:Init()
	self:SetCommand("gender");
	self:SetLabel("Gender");

	local contents = vgui.Create("DButton", self);
	contents:SetContentAlignment(5);
	contents:SetDisabled(true);
	self:SetContents(contents);
end

function PANEL:DoClick()
	local menu = DermaMenu();

	menu:AddOption("Male", function()
		self:Command("male");
	end);
	menu:AddOption("Female", function()
		self:Command("female");
	end);

	menu:Open();
end

function PANEL:Think()
	-- FIXME: Why a think?
	self.contents:SetText(LocalPlayer()._Gender or "Male");
end

vgui.Register("cider_Character_Gender", PANEL, "cider_Character_Editor");

-- function PANEL:PerformLayout()
-- 	self.label:SetPos(8, 5);
-- 	self.label:SizeToContents();
-- 	self.button:SizeToContents();
-- 	self.button:SetTall(16);
-- 	self.button:SetWide(self.button:GetWide() + 16);
-- 	self.textEntry:SetSize(self:GetWide() - self.button:GetWide() - self.label:GetWide() - 32, 16);
-- 	self.textEntry:SetPos(self.label.x + self.label:GetWide() + 8, 5);
-- 	self.button:SetPos(self.textEntry.x + self.textEntry:GetWide() + 8, 5);
-- end

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetDark(true);

	-- The description of the team.
	self.description = vgui.Create("DLabel", self);
	self.description:SetDark(true);

	-- Set the size of the panel.
	self:SetSize(cider.menu.width, 75);

	-- Create the button and the spawn icon.
	self.button = vgui.Create("DButton", self);
	function self.button:DoClick()
		RunConsoleCommand("mshine", "team", self.tid);
	end
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() end;
	self.spawnIcon.OnMousePressed = function() end;

end

function PANEL:SetTeam(team)
	self.Team = team;
	self.TeamID = team.TeamID;
	self.Models = team.Models;
	self.description:SetText(self.Team.Description);
	self.button:SetText("Become");
	self.button.tid = team.TeamID;
	if (team.SizeLimit == 0) then
		self.nolimit = true;
		self.label:SetText(team.Name);
	end
	if (lpl:Team() == self.TeamID) then
		self.button:SetText("Joined");
		self.button:SetDisabled(true);
		self.NoButton = true;
	else
		local c = nextChanges[self.TeamID];
		if (c and c > CurTime()) then
			self.cd = true;
		end
	end
	self:Think();
end

-- Called every frame.
function PANEL:Think()
	local gender = lpl._NextSpawnGender or "";
	if (gender == "") then
		gender = lpl._Gender or "";
		if (gender == "") then
			gender = "Male";
		end
	end
	if (gender ~= self.gender) then
		self.gender = gender;
		local model = self.Models[gender][lpl._ModelChoices[gender][self.TeamID]]
		self.spawnIcon:SetModel(model);
	end
	local nump = team.NumPlayers(self.TeamID);
	if (not self.nolimit and self.LastNump ~= nump) then
		self.LastNump = nump;
		self.label:SetText(self.Team.Name .. " (" .. nump .. "/" .. self.Team.SizeLimit .. ")");
		if (not self.NoButton and nump >= self.Team.SizeLimit) then
			self.button:SetDisabled(true);
			self.button:SetText("Full");
		end
	end
	if (self.NoButton or not self.cd) then return; end
	local c = nextChanges[self.TeamID];
	local ct = CurTime();
	if (c and c > ct) then
		self.button:SetDisabled(true);
		self.button:SetText("Wait "..string.ToMinutesSeconds(c - ct));
	else
		self.cd = false;
		self.button:SetDisabled(false);
		self.button:SetText("Become")
	end
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(4, 5);
	self.label:SetPos(self.spawnIcon.x + self.spawnIcon:GetWide() + 8, 5);
	self.label:SizeToContents();
	self.description:SetPos(self.spawnIcon.x + self.spawnIcon:GetWide() + 8, 24);
	self.description:SizeToContents();
	self.button:SetPos( self.spawnIcon.x + self.spawnIcon:GetWide() + 8, self.spawnIcon.y + self.spawnIcon:GetTall() - self.button:GetTall() )
end

-- Register the panel.
vgui.Register("cider_Character_Team", PANEL, "DPanel");
