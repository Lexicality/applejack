--[[
	~ MSAccessList ~
	~ Moonshine ~
--]]

-- Vars
local menu;

-- Usage
local function CreateMenu(data)
	if (IsValid(menu)) then
		menu:Close();
		menu:Remove();
		menu = nil;
	end
	local width = 800;
	local height = ScrH() * 0.75;
	menu = vgui.Create("MSAccessList");
	menu:SetSize(width, height);
	menu:SetData(data);
	menu:MakePopup();
end

local function UpdateMenu(data)
	if (not IsValid(menu)) then
		MsgN("Sent an access menu update with no access menu open!");
		return;
	end
	menu:SetData(data);
end

if (net) then
	net.Receive("MS Access List", function()
		CreateMenu(net.ReadTable());
	end);
	net.Receive("MS Access List update", function()
		UpdateMenu(net.ReadTable());
	end);
else
	datastream.Hook("MS Access List", function(_,_,_, data)
		CreateMenu(data);
	end);
	datastream.Hook("MS Access List update", function(_,_,_, data)
		UpdateMenu(data);
	end);
end

----------------------------------------
----------------------------------------
----                                ----
----       Utility Functions        ----
----                                ----
----------------------------------------
----------------------------------------

-- Util
local function verifyPos()
	-- TODO: Put this in the think hook. Why is it out here??
	if (not IsValid(menu)) then
		return false;
	end
	-- Ensure they're where they were when they opened the menu.
	if (lpl:GetPos() == menu.OpenPos) then
		return true;
	end
	-- They've moved. This probably breaks everything so give up
	menu:Close();
	menu:Remove();
	gui.EnableScreenClicker(false);
	return false;
end

-- Button functions
local takeFunction;
local giveFunction;
do
	local function btn(what, how)
		local uid;
		if (what.IsPlayer) then
			if (IsValid(what)) then
				uid = what:UniqueID();
			end
		else
			uid = what.UniqueID;
		end
		if (uid) then
			RunConsoleCommand("mshine", "access", how, uid);
		end
	end
	local function giveAccess(what)
		btn(what, "give");
	end
	local function takeAccess(what)
		btn(what, "take");
	end
	local function itemfunction(panel, item)
		local name, desc, mdl
		if (item.IsPlayer) then
			name = item:GetName();
			desc = "TODO! Details - Clan";
			mdl  = item:GetModel();
		else
			name = item.Name;
			desc = item.Description;
			mdl  = item.Model;
		end
		panel:SetName(name);
		panel:SetDescription(desc);
		panel:SetPortrait(mdl);
	end
	function giveFunction(panel, item)
		itemfunction(panel, item);
		panel:AddButton("Give Access", giveAccess);
	end
	function takeFunction(panel, item)
		itemfunction(panel, item);
		panel:AddButton("Take Access", takeAccess);
	end
end

----------------------------------------
----------------------------------------
----                                ----
----      List Formatting           ----
----                                ----
----------------------------------------
----------------------------------------

local function sortPlayerFunc(a, b)
	return a:Name() < b:Name();
end

local function sortTeamFunc(a, b)
	return a.SortWeight < b.SortWeight or a.Name < b.Name;
end

local function sortGangFunc(a, b)
	--[[
	-- Make sure groups are always above gangs
	if (a.IsGroup) then
		if (b.IsGroup) then
			-- If they're both groups, sort normally.
			return sortTeamFunc(a, b);
		else
			-- Otherwise, bump A above B.
			return true;
		end
	elseif (b.IsGroup) then
		-- Reverse situation: B is a group but A isn't. Knock A below B
		return false;
	else
		-- Neither is a group, sort normally.
		return sortTeamFunc(a, b);
	end
	--]]
	return a.IsGroup and (not b.IsGroup or sortTeamFunc(a, b)) or (not b.IsGroup and sortTeamFunc(a, b));
end

local function formatPlayerList(list)
	local res = {};
	local trans = {};
	for _, group in pairs(GM.Groups) do
		local data = {
			SortWeight = group.SortWeight;
		};
		for _, team in pairs(group.Teams) do
			local arf = {
				SortWeight = team.SortWeight;
			};
			data[team.Name] = arf;
			trans[team.TeamID] = arf;
		end
		res[group.Name] = data;
	end

	for _, ply in pairs(list) do
		local data = trans[ply:Team()];
		if (not data) then
			continue;
		end
		table.insert(data, ply);
	end

	for name, gdata in pairs(res) do
		local hasdata = false;
		for name, tdata in pairs(gdata) do
			if (name == "SortWeight") then
				continue;
			end
			if (#tdata > 0) then
				hasdata = true;
				table.sort(tdata, sortname);
			else
				gdata[name] = nil;
			end
		end
		if (not hasdata) then
			res[name] = nil;
		end
	end

	return res;
end

---
-- Turns a list of players into a suitable category list
--  for use in a MSItemList panel
local function preparePlayerData(PlayerList)
	local TeamIDs = {};
	local ItemData = {};
	-- Make sure we only do the paperwork for teams we need
	for _, Player in pairs(PlayerList) do
		TeamIDs[Player:Team()] = true;
	end
	-- Generate the category headings for all the players.
	for TeamID in pairs(TeamIDs) do
		local Team = GM.Teams[TeamID];
		-- Make sure it's not one of the metateams like Connecting or something
		if (not Team or Team.Invisible) then
			TeamIDs[TeamID] = nil;
			continue;
		end
		-- Group stuffs
		local Group = Team.Group;
		local GroupData = ItemData[Group.Name];
		-- Generate the group category if it doesn't exist
		if (not GroupData) then
			GroupData = {
				SortWeight = Group.SortWeight;
				Unaffiliated = {
					-- Plunge to the bottom
					SortWeight = 10;
				};
			};
			ItemData[Group.Name] = GroupData;
		end
		-- Gang stuff
		local Gang = TeamData.Gang;
		local GangData;
		if (Gang) then
			GangData = GroupData[Gang.Name];
			if (not GangData) then
				-- Generate the gang subcategory
				GangData = {
					SortWeight = Gang.SortWeight;
				};
				GroupData[Gang.Name] = GangData;
			end
		else
			GangData = Group.Unaffiliated;
		end
		-- Finally get around to making the team subcategory
		local TeamData = {
			SortWeight = Team.SortWeight;
		};
		GangData[Team.Name] = TeamData;
		-- And for the porpoises of actually getting the players in,
		--  alias the category table as a TeamID Subtable
		TeamIDs[TeamID] = TeamData;
	end
	-- Finally, the simple task of just adding the players to the relevent team tables
	for _, Player in pairs(PlayerList) do
		local TeamData = TeamIDs[Player:Team()];
		if (not TeamData) then
			-- We don't want this player in here
			continue;
		end
		table.insert(TeamData, Player);
	end
	-- All the tables are now populated! (But not sorted)
	return ItemData;
end

local function formatTeamList(list)
	local res = {};
	local trans = {};

	for _, group in pairs(GM.Groups) do
		local gangs = {
			SortWeight = group.SortWeight;
		};
		for _, gang in (data.Gangs) do
			local teams = {
				SortWeight = gang.SortWeight;
			};
			for _, team in pairs(gang.Teams) do
				trans[team.TeamID] = teams;
			end
			gangs[gang.Name] = teams;
		end
		teams = {
			SortWeight = 10;
	}
		for _, team in pairs(group.Teams) do
			if (not trans[team.TeamID]) then
				trans[team.TeamID] = teams;
			end
		end
		gangs["Unaffiliated"] = teams;
		res[data.Name] = gangs;
	end

	for _, id in pairs(list) do
		local team = GM.Teams[id];
		if (not team) then
			continue;
		end
		local data = trans[team.TeamID];
		if (not data) then
			continue;
		end
		table.insert(data, team);
	end

	for name, gdata in pairs(res) do
		local hasdata = false;
		for name, tdata in pairs(gdata) do
			if (name == "SortWeight") then
				continue;
			end
			if (#tdata > 0) then
				hasdata = true;
				table.sort(tdata, sortfunc);
			else
				gdata[name] = nil;
			end
		end
		if (not hasdata) then
			res[name] = nil;
		end
	end

	return res;
end

function prepareTeamData(TeamList)
	-- Pillaged from preparePlayerData
	local TeamIDs = {};
	local ItemData = {};
	-- Make sure we only do the paperwork for teams we need
	for _, TeamID in pairs(TeamList) do
		TeamIDs[TeamID] = true;
	end
	-- Generate the category headings for all the players.
	for TeamID in pairs(TeamIDs) do
		local Team = GM.Teams[TeamID];
		-- Make sure it's not one of the metateams like Connecting or something
		if (not Team or Team.Invisible) then
			TeamIDs[TeamID] = nil;
			continue;
		end
		-- Group stuffs
		local Group = Team.Group;
		local GroupData = ItemData[Group.Name];
		-- Generate the group category if it doesn't exist
		if (not GroupData) then
			GroupData = {
				SortWeight = Group.SortWeight;
				Unaffiliated = {
					-- Plunge to the bottom
					SortWeight = 10;
				};
			};
			ItemData[Group.Name] = GroupData;
		end
		-- Gang stuff
		local Gang = TeamData.Gang;
		local GangData;
		if (Gang) then
			GangData = GroupData[Gang.Name];
			if (not GangData) then
				-- Generate the gang subcategory
				GangData = {
					SortWeight = Gang.SortWeight;
				};
				GroupData[Gang.Name] = GangData;
			end
		else
			GangData = Group.Unaffiliated;
		end
		-- Aaand we're done. Just drop the team information into the relevent gang slot
		table.insert(GangData, TeamData);
	end
	return ItemData;
end

local function formatGangList(list)
	local groups = {};
	local gangs = {};
	for _, id in pairs(list) do
		if (id < 0) then
			groups[-id] = true;
		else
			gangs[id] = true;
		end
	end
	local res = {};
	for _, group in pairs(GM.Groups) do
		local data = {
			SortWeight = group.SortWeight;
		};
		for _, gang in pairs(group.Gangs) do
			if (gangs[gang.GangID]) then
				table.insert(data, gang);
			end
		end
		if (groups[group.GroupID]) then
			table.insert(data, group);
		end
		if (#data > 0) then
			res[group.Name] = data;
		end
	end
	return ret;
end

function pepareGangData(GangList)
	local ItemData = {};
	local GroupIDs = {};
	local GangIDs = {};
	for _, ID in pairs(GangList) do
		if (ID < 0) then
			-- IDs < 0 indicate entire groups
			GroupIDs[-ID] = true; -- Invert ID for normal ID
		else
			GangIDs[ID] = true;
		end
	end
	-- Have a category for every group, even if nothing's in it
	for _, GroupData in pairs(GM.Groups) do
		local Group = { SortWeight = GroupData.SortWeight; }
		if (GroupIDs[GroupData.ID]) then
			table.insert(Group, GroupData);
		end
		for _, GangData in pairs(GroupData.Gangs) do
			if (GangIDs[GangData.ID]) then
				table.insert(Group, GangData);
			end
		end
		ItemData[GroupData.Name] = Group;
	end
	return ItemData;
end

local function prepPlayers(data)
	local ret = {};
	ret.Peons = preparePlayerData(data.Players.Peons);
	ret.Peers = preparePlayerData(data.Players.Peers);
	ret.SortFunction = sortPlayerFunc;
	return ret;
end

local function prepTeams(data)
	local ret = {};
	ret.Peons = prepareTeamData(data.Teams.Peons);
	ret.Peers = prepareTeamData(data.Teams.Peers);
	ret.SortFunction = sortTeamFunc;
	return ret;
end

local function prepGangs(data)
	local ret = {};
	ret.Peons = prepareGangData(data.Gangs.Peons);
	ret.Peers = prepareGangData(data.Gangs.Peers);
	ret.SortFunction = sortGangFunc;
	return ret;
end
----------------------------------------
----------------------------------------
----                                ----
----     Main Access List Derma     ----
----                                ----
----------------------------------------
----------------------------------------
local tabPane;

PANEL = {};

function PANEL:Initialize()
	-- To detect if the player gets knocked out of the way
	-- TODO: Far better thing to do would be to check if they're still looking at the right entity.
	self.OpenPos = lpl:GetPos();
	-- Master DFrame stuffs
	self:SetTitle("Access Menu");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(true);
	-- We're replacing the tiny X with a bigger CLOSE button
	self:ShowCloseButton(false);
	-- Creation
	self.Players = vgui.CreateFromTable(tabPane, self);
	self.Panes = vgui.Create("DPropertySheet", self);
	self.Teams = vgui.CreateFromTable(tabPane, self);
	self.Gangs = vgui.CreateFromTable(tabPane, self);
	-- Strip above the tabs etc.
	self.TopBackground = vgui.Create("DPanel", self);
	local bkgrnd = self.TopBackground;
	bkgrnd.CloseButton = vgui.Create("DButton", bkgrnd);
	bkgrnd.SellButton = vgui.Create("DButton", bkgrnd);
	bkgrnd.SetNameButton = vgui.Create("DButton", bkgrnd);
	bkgrnd.SetNameBox = vgui.Create("DTextEntry", bkgrnd);

	-- Initialization
	self.Panes:AddSheet("Players", self.Players);
	self.Panes:AddSheet("Teams", self.Teams);
	self.Panes:AddSheet("Gangs", self.Gangs);
	bkgrnd.CloseButton:SetText("Close");
	bkgrnd.SellButton:SetText("Sell");
	bkgrnd.SetNameButton:SetText("Set Name");

	-- Button callbacks
	do
		local this = self;
		local function doclose()
			this:Close();
			gui.EnableScreenClicker(false);
		end
		local function finishsell()
			RunConsoleCommand("mshine", "entity", "sell");
			doclose();
		end
		local function dosell()
			local menu = DermaMenu();
			menu:AddOption("No");
			menu:AddOption("yes", finishsell);
			menu:Open();
		end
		local function doname()
			local text = bkgrnd.SetNameBox:GetValue();
			if (text == "") then
				return;
			end
			text = string.sub(text, 1, 32);
			RunConsoleCommand("mshine", "entity", "rename", text);
			bkgrnd.SetNameBox:SetValue("");
			bkgrnd.SetNameBox:KillFocus();
		end
		bkgrnd.CloseButton.DoClick = doclose;
		bkgrnd.SellButton.DoClick = dosell;
		bkgrnd.SetNameBox.OnEnter = doname;
		bkgrnd.SetNameButton.DoClick = doname;
	end

	-- Positioning
	self.TopBackground:Dock(TOP);
	self.Panes:Dock(FILL);
end

function PANEL:SetData(data)
	self.Players:SetData(prepPlayers(data));
	self.Teams:SetData(prepTeams(data));
	self.Gangs:SetData(prepGangs(data));
end

function PANEL:PerformLayout()
	-- TODO
end

vgui.Register("MSAccessList", PANEL, "DFrame");

PANEL = {};

function PANEL:Initialize()
	local peerlist = vgui.Create("MSItemList", self);
	local peonlist = vgui.Create("MSItemList", self);

	-- Layout
	peerlist:Dock(LEFT);
	peonlist:Dock(RIGHT);
	-- Save the lists for later
	self.Peers = peerlist;
	self.Peons = peonlist;
end

function PANEL:PerformLayout()
	local width = (self:GetWide() / 2) - 8
	self.Peers:SetWide(width);
	self.Peons:SetWide(width);
	self.Peers:InvalidateLayout();
	self.Peons:InvalidateLayout();
end

function PANEL:SetData(data)
	self.Peers:SetItems(data.Peers);
	self.Peons:SetItems(data.Peons);
end

tabPane = vgui.RegisterTable(PANEL, "DPanel");
