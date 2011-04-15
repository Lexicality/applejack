--[[
Name: "cl_character.lua".
	~ Applejack ~
--]]

local PANEL = {};
local lpl = LocalPlayer()
local teamChanged = false;
--	LocalPlayer()._NextChangeTeam = {}
local function CheckForInitalised(number)
	if !ValidEntity(LocalPlayer()) then
		return timer.Simple(1,CheckForInitalised,number)
	end
	LocalPlayer()._NextChangeTeam = LocalPlayer()._NextChangeTeam or {}
	LocalPlayer()._NextChangeTeam[ number ] = CurTime() + team.Query(number,"Cooldown",300);
	timer.Simple(0.1,function() teamChanged = true end)
end	
usermessage.Hook("TeamChange", function(msg)
	local team = msg:ReadShort() or 0
	CheckForInitalised(team)
end)


-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cider.menu.width, cider.menu.height - 8);
	if !ValidEntity(lpl) then lpl = LocalPlayer() end
	lpl._NextChangeTeam = lpl._NextChangeTeam or {}
	-- Create a panel list to store the items.
	self.itemsList = vgui.Create("DPanelList", self);
 	self.itemsList:SizeToContents();
 	self.itemsList:SetPadding(2);
 	self.itemsList:SetSpacing(3);
	self.itemsList:StretchToParent(4, 4, 12, 44);
	self.itemsList:EnableVerticalScrollbar();
	-- We'll do the rest in the think func
	teamChanged = true
	if not lpl._ModelChoices then
		lpl._ModelChoices = {}
		for _,team in pairs(cider.team.stored) do
			for gender,models in pairs(team.models) do
				lpl._ModelChoices[gender] = lpl._ModelChoices[gender] or {}
				if #models ~= 1 then
					lpl._ModelChoices[gender][team.index]
						= math.random(1,#models)
				else
					lpl._ModelChoices[gender][team.index] = 1
				end
			end
		end
	end
end

local thinktest = CurTime()
function PANEL:Think()
	if not teamChanged then return end
	if not ValidEntity(lpl) then lpl = LocalPlayer() end
	if not lpl._ModelChoices then
		if thinktest > CurTime() then
			thinktest = CurTime() + 1
			print(lpl,lpl._ModelChoices,LocalPlayer(),LocalPlayer()._ModelChoices)
		end
		return
	end
	teamChanged = false
	print("Model Choices are valid - filling out character list now.")
	local lgroup = team.Query(lpl:Team(), "Group");
	--Wipe the itemlist so we can renew it
	self.itemsList:Clear()
	-- Create the job control.
	self.job = vgui.Create("cider_Character_TextEntry", self);
	self.job.label:SetText("Job");
	self.job.label:SizeToContents();
	self.job.button:SetText("Change");
	self.job.button.DoClick = function()
		RunConsoleCommand( "cider", "job", self.job.textEntry:GetValue() );
	end
	
	-- Create the clan control.
	self.clan = vgui.Create("cider_Character_TextEntry", self);
	self.clan.label:SetText("Clan");
	self.clan.label:SizeToContents();
	self.clan.button:SetText("Change");
	self.clan.button.DoClick = function()
		RunConsoleCommand( "cider", "clan", self.clan.textEntry:GetValue() );
	end
	
	-- Create the details control.
	self.details = vgui.Create("cider_Character_TextEntry", self);
	self.details.label:SetText("Details");
	self.details.label:SizeToContents();
	self.details.button:SetText("Change");
	self.details.button.DoClick = function()
		RunConsoleCommand( "cider", "details", self.details.textEntry:GetValue() );
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
	
	--Store the list of groups here sorted by index
	local groups = {}
	for k,v in pairs(cider.team.storedgroups) do groups[v.index] = v end
	-- Loop through each of our groups
	for index,group in ipairs(groups) do
		local header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(cider.menu.width, 50); -- Keep the second number at 50
		header:SetLabel( group.name )
		header:SetExpanded(lgroup == group)
		header:SetToolTip( group.description )
		self.itemsList:AddItem(header);
		local subitemsList = vgui.Create("DPanelList", self);
		subitemsList:SetAutoSize( true ) 
		subitemsList:SetPadding(2);
		subitemsList:SetSpacing(3);
		header:SetContents( subitemsList )	
		header.ilist = subitemsList
		-- Store the list of teams here sorted by their index.
		local teams = {};
		
		-- Loop through the available teams.
		for k, v in pairs(group.teams) do
	--		print(k,v)
			teams[k] = cider.team.get(v);
			--print(cider.team.stored[v])
		end
		--PrintTable(group)
		--PrintTable(teams)
		-- Loop through our sorted teams.
		for k, v in ipairs(teams) do
			self.currentTeam = v.name;
			--Check they can join the team
			if GAMEMODE:PlayerCanJoinTeamShared(LocalPlayer(),v.index) then
				-- Create the team panel.
				local panel = vgui.Create("cider_Character_Team", self);
				
				-- Set the text of the label.
				panel.label:SetText(v.name.." ("..team.NumPlayers(v.index).."/"..v.limit..")");
				panel.label.Think = function()
					panel.label:SetText(v.name.." ("..team.NumPlayers(v.index).."/"..v.limit..")");
					panel.label:SizeToContents();
				end
				panel.description:SetText(v.description);
				panel.button:SetText("Become");
				panel.button.Think = function()
					if (lpl:Team() == v.index) then
						panel.button:SetDisabled(true);
						panel.button:SetText("Joined")
					else
						if (team.NumPlayers(v.index) >= v.limit) then
							panel.button:SetDisabled(true);
							panel.button:SetText("Full")
						elseif lpl._NextChangeTeam[v.index] and lpl._NextChangeTeam[v.index] > CurTime() then
							panel.button:SetDisabled(true)
							panel.button:SetText("Wait "..string.ToMinutesSeconds(lpl._NextChangeTeam[v.index]-CurTime()))
						else
							panel.button:SetDisabled(false);
							panel.button:SetText("Become")
						end
					end
				end
				panel.button.DoClick = function()
					RunConsoleCommand("cider", "team", v.index);
				end
				
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
		menu:AddOption("Male", function() RunConsoleCommand("cider", "gender", "male"); end);
		menu:AddOption("Female", function() RunConsoleCommand("cider", "gender", "female"); end);
		
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
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Get the team from the parent and set the gender of the spawn icon.
	self.team = self:GetParent().currentTeam;
	self.gender = "Male";
	
	local gender,name = "male",cider.team.query(self.team,"index")
--	print(gender,name)
	local models = cider.team.stored[self.team].models[ gender ];
	local model = models[LocalPlayer()._ModelChoices[gender][name]]
	-- Get a random model from the table.
--	print(model,LocalPlayer()._ModelChoices[gender][name])
--	local models = cider.team.stored[self.team].models.male
--	local model = models[ math.random(1, #models) ];
	
	-- Set the model of the spawn icon to the one of the team.
	self.spawnIcon:SetModel(model);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() return; end
	self.spawnIcon.OnMousePressed = function() return; end
end

-- Called every frame.
function PANEL:Think()
	local _Gender = LocalPlayer()._NextSpawnGender or "";
	
	-- Check if the next spawn gender is valid.
	if (_Gender == "") then _Gender = LocalPlayer()._Gender or "Male"; end
	if (_Gender == "") then _Gender = "Male"; end
	
	-- Check if our gender is different.
	if (self.gender ~= _Gender) then
		local gender,name = string.lower(_Gender),cider.team.query(self.team,"index")
--		print(gender,name)
		local models = cider.team.stored[self.team].models[ gender ];
		local model = models[LocalPlayer()._ModelChoices[gender][name]]
--		print(model,LocalPlayer()._ModelChoices[gender][name])
--		print(LocalPlayer()._ModelChoices[gender])
--		PrintTable(LocalPlayer()._ModelChoices)
		--local model = models[ math.random(1, #models) ];
		
		-- Set the model to our randomly selected one.
		self.spawnIcon:SetModel(model);
		
		-- We've changed our gender now so set it to this one.
		self.gender = _Gender;
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
