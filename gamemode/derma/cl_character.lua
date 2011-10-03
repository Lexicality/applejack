--[[
Name: "cl_character.lua".
	~ Applejack ~
--]]

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
		for index, team in pairs(GM.Teams) do
			for gender,models in pairs(team.Models) do
				lpl._ModelChoices[gender] = lpl._ModelChoices[gender] or {}
				if #models ~= 1 then
					lpl._ModelChoices[gender][index] = math.random(1,#models)
				else
					lpl._ModelChoices[gender][index] = 1
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
	-- Create the job control.
	self.job = vgui.Create("cider_Character_TextEntry", self);
	self.job.label:SetText("Job");
	self.job.label:SizeToContents();
	self.job.button:SetText("Change");
	self.job.button.DoClick = function()
		RunConsoleCommand( "mshine", "job", self.job.textEntry:GetValue() );
	end
	
	-- Create the clan control.
	self.clan = vgui.Create("cider_Character_TextEntry", self);
	self.clan.label:SetText("Clan");
	self.clan.label:SizeToContents();
	self.clan.button:SetText("Change");
	self.clan.button.DoClick = function()
		RunConsoleCommand( "mshine", "clan", self.clan.textEntry:GetValue() );
	end
	
	-- Create the details control.
	self.details = vgui.Create("cider_Character_TextEntry", self);
	self.details.label:SetText("Details");
	self.details.label:SizeToContents();
	self.details.button:SetText("Change");
	self.details.button.DoClick = function()
		RunConsoleCommand( "mshine", "details", self.details.textEntry:GetValue() );
	end
	local details = lpl:GetNWString("Details") or ""
	self.details.textEntry:SetValue(details)
	
	-- Create the gender control.
	self.gender = vgui.Create("cider_Character_Gender", self);
	self.gender.label:SetText("Gender");
	self.gender.label:SizeToContents();
	self.gender.button:SetText("Change");
	
	-- Add the controls to the item list.
	self.itemsList:AddItem(self.job);
	self.itemsList:AddItem(self.clan);
	self.itemsList:AddItem(self.details);
	self.itemsList:AddItem(self.gender);
	
	-- Loop through each of our groups in numerical order
	for index, group in ipairs(GM.Groups) do
		if (group.Invisible) then continue; end
		local header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(cider.menu.width, 50); -- Keep the second number at 50
		header:SetLabel( group.Name )
		header:SetExpanded(lgroup == group)
		header:SetToolTip( group.Description )
		self.itemsList:AddItem(header);
		local subitemsList = vgui.Create("DPanelList", self);
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

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SizeToContents();
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.textEntry = vgui.Create("DTextEntry", self);
	
	-- Create the button.
	self.button = vgui.Create("DButton", self);
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(8, 5);
	self.label:SizeToContents();
	self.button:SizeToContents();
	self.button:SetTall(16);
	self.button:SetWide(self.button:GetWide() + 16);
	self.textEntry:SetSize(self:GetWide() - self.button:GetWide() - self.label:GetWide() - 32, 16);
	self.textEntry:SetPos(self.label.x + self.label:GetWide() + 8, 5);
	self.button:SetPos(self.textEntry.x + self.textEntry:GetWide() + 8, 5);
end
	
-- Register the panel.
vgui.Register("cider_Character_TextEntry", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SizeToContents();
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.textButton = vgui.Create("DButton", self);
	self.textButton:SetDisabled(true);
	
	-- Create the button.
	self.button = vgui.Create("DButton", self);
	self.button.DoClick = function()
		local menu = DermaMenu();
		
		-- Add male and female options to the menu.
		menu:AddOption("Male", function() RunConsoleCommand("mshine", "gender", "male"); end);
		menu:AddOption("Female", function() RunConsoleCommand("mshine", "gender", "female"); end);
		
		-- Open the menu and set it's position.
		menu:Open();
	end
end

-- Called every frame.
function PANEL:Think()
	self.textButton:SetText(LocalPlayer()._Gender or "Male");
	self.textButton:SetContentAlignment(5);
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(8, 5);
	self.label:SizeToContents();
	self.button:SizeToContents();
	self.button:SetTall(16);
	self.button:SetWide(self.button:GetWide() + 16);
	self.textButton:SetSize(self:GetWide() - self.button:GetWide() - self.label:GetWide() - 32, 16);
	self.textButton:SetPos(self.label.x + self.label:GetWide() + 8, 5);
	self.button:SetPos(self.textButton.x + self.textButton:GetWide() + 8, 5);
end
	
-- Register the panel.
vgui.Register("cider_Character_Gender", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	
	-- The description of the team.
	self.description = vgui.Create("DLabel", self);
	self.description:SetTextColor( Color(255, 255, 255, 255) );
	
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
