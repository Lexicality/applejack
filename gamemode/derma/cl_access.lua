--[[
Name: "cl_containr.lua".
	~ Applejack ~
--]]
local PANEL = {};
local width,height = ScrW()*0.75,ScrH()*0.75
local accessmenu
local localPlayerPosition
local CurTab
local function CheckPos()
	if localPlayerPosition ~= LocalPlayer():GetPos() then
		accessmenu:Close();
		accessmenu:Remove();

		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		return false
	end
	return true
end
--[[
local cmo = RunConsoleCommand
local RunConsoleCommand = function(...)
	print(...)
	cmo(...)
end
--]]
-- Called when the panel is initialized.
function PANEL:Init()
--	self:StretchToParent(0,0,width/2+10,0)
	self:SetSize(width/2 -10, height - 55);
	--local p = self:GetParent()
	--self:SetSize(p:GetWide()/2 -10, p:GetTall() - 600);
	--self:SetWide(width/2 -10)

	-- Create a panel list to store the items.
	self.itemsList = vgui.Create("DPanelList", self);
 	self.itemsList:SizeToContents();
 	self.itemsList:SetPadding(2);
 	self.itemsList:SetSpacing(3);
	self.itemsList:StretchToParent(4, 4, 12, 0);
	self.itemsList:EnableVerticalScrollbar();

	self.updatePanel = false
	self.inventory = {}
	self.action = "error"
	self.type = "error"
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
--	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end

local function handlePlys(self)
	local res, header, sublist, subsublist, item, str;
	for gid, ts in pairs(self.inventory) do
		for tid, ps in pairs(ts) do
			if (#ps == 0) then
				ts[tid] = nil;
			end
		end
		if (table.Count(ts) == 0) then
			self.inventory[gid] = nil;
		end
	end
	if (table.Count(self.inventory) == 0) then
		return;
	end
	for GroupID, teams in SortedPairs(self.inventory) do
		res = GM:GetGroup(GroupID);
		header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(width/2, 50); -- Keep the second number at 50
		header:SetLabel(res.Name);
		header:SetToolTip(res.Description);
		self.itemsList:AddItem(header);
		sublist = vgui.Create("DPanelList", self);
		sublist:SetAutoSize(true)
		sublist:SetPadding(2);
		sublist:SetSpacing(3);
		header:SetContents(sublist);
		for TeamID, plys in SortedPairs(teams) do
			res = team.Get(TeamID);
			header = vgui.Create("DCollapsibleCategory", self);
			header:SetSize(width/2, 50); -- Keep the second number at 50
			header:SetLabel(res.Name);
			header:SetToolTip(res.Description);
			sublist:AddItem(header);
			subsublist = vgui.Create("DPanelList", self);
			subsublist:SetAutoSize(true)
			subsublist:SetPadding(2);
			subsublist:SetSpacing(3);
			header:SetContents(subsublist);
			for _, ply in ipairs(plys) do
				item = vgui.Create("Accessmenu Item", self);
				str = ply:GetNWString("Clan");
				if (str ~= "") then
					str = ply:Name() .. " (" .. str .. ")";
				else
					str = ply:Name();
				end
				item:SetName(str);
				str = ply:GetNWString("Details");
				if (str == "") then
					str = "- No Details Set -";
				end
				item:SetDescription(str);
				item:SetModel(ply:GetModel());
				item:SetIdentifier("player", ply:UserID());
				item:SetButton(ply ~= lpl and accessmenu.owned);
				subsublist:AddItem(item);
			end
		end
	end	
end

local function handleTeams(self)
	local res, header, sublist, item;
	for gid, ts in pairs(self.inventory) do
		if (table.Count(ts) == 0) then
			self.inventory[gid] = nil;
		end
	end
	if (table.Count(self.inventory) == 0) then
		return;
	end
	for GroupID, teams in SortedPairs(self.inventory) do
		res = GM:GetGroup(GroupID);
		header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(width/2, 50); -- Keep the second number at 50
		header:SetLabel(res.Name);
		header:SetToolTip(res.Description);
		self.itemsList:AddItem(header);
		sublist = vgui.Create("DPanelList", self);
		sublist:SetAutoSize(true)
		sublist:SetPadding(2);
		sublist:SetSpacing(3);
		header:SetContents(sublist);
		for _, team in SortedPairs(teams) do
			item = vgui.Create("Accessmenu Item", self);
			item:SetName(team.Name);
			item:SetDescription(team.Description);
			item:SetModel(table.Random(table.Random(team.Models)));
			item:SetIdentifier("team", team.TeamID);
			item:SetButton(accessmenu.owned);
			sublist:AddItem(item);
		end
	end
end

local function handleGangs(self)
	local res, header, sublist, item;
	for gid, gs in pairs(self.inventory) do
		if (table.Count(gs) == 0) then
			self.inventory[gid] = nil;
		end
	end
	if (table.Count(self.inventory) == 0) then
		return;
	end
	for GroupID, gangs in SortedPairs(self.inventory) do
		res = GM:GetGroup(GroupID);
		header = vgui.Create("DCollapsibleCategory", self)
		header:SetSize(width/2, 50); -- Keep the second number at 50
		header:SetLabel(res.Name);
		header:SetToolTip(res.Description);
		self.itemsList:AddItem(header);
		sublist = vgui.Create("DPanelList", self);
		sublist:SetAutoSize(true)
		sublist:SetPadding(2);
		sublist:SetSpacing(3);
		header:SetContents(sublist);
		for _, gang in SortedPairs(gangs) do
			item = vgui.Create("Accessmenu Item", self);
			item:SetName(gang.Name);
			item:SetDescription(gang.Description);
			item:SetModel(gang.Model);
			if (_ == 0) then
				item:SetIdentifier("group", GroupID);
			else			
				item:SetIdentifier("gang", gang.GangID);
			end			
			item:SetButton(accessmenu.owned);
			sublist:AddItem(item);
		end
	end
end

-- Called every frame.
function PANEL:Think()
	if (not self.updatePanel) then return; end
	self.updatePanel = false;

	-- Clear the current list of items.
	self.itemsList:Clear();
	local info = vgui.Create("Accessmenu Header", self)
	info.word = self.name
	self.itemsList:AddItem(info);
	if (self.isply) then
		handlePlys(self);
	elseif (self.isteam) then
		handleTeams(self);
	else
		handleGangs(self);
	end
	-- Rebuild the items list.
	self.itemsList:Rebuild();
end

-- Register the panel.
vgui.Register("Accessmenu List", PANEL, "Panel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	-- Set the size and position of the panel.
	self:SetSize(width/2, 75);
	self:SetPos(1, 5);
	self.name = vgui.Create("DLabel", self);
	self.name:SetTextColor(Color(255, 255, 255));
	self.description = vgui.Create("DLabel", self);
	self.description:SetTextColor(Color(255, 255, 255));
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() end;
	self.spawnIcon.OnMousePressed = function() end;
end

function PANEL:SetName(name)
	self.name:SetText(name);
	self.name:SizeToContents();
end

function PANEL:SetDescription(desc)
	self.description:SetText(desc);
	self.description:SizeToContents();
end

function PANEL:SetModel(model)
	self.spawnIcon:SetModel(model)
end

function PANEL:SetIdentifier(idkind, id)
	self.idkind = idkind;
	self.id = id;
end
	
local function btn(self)
	if (accessmenu.Buttoned or not CheckPos()) then
		return false;
	end
	CurTab = accessmenu.sheets:GetActiveTab()
	accessmenu.Buttoned = true
	RunConsoleCommand("cider", "entity", self.action, self.me.idkind, self.me.id);
end
function PANEL:SetButton(bool)
	if (not bool) then return; end
	self.button = vgui.Create("DButton", self);
	local action = self:GetParent().action
	self.button:SetText(action);
	self.button.action = string.lower(action);
	self.button.me = self;
	self.button.DoClick = btn;
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(4, 5);
	self.name:SizeToContents();
	self.description:SetPos(75, 24);
	self.description:SizeToContents();

	-- Define the x position of the item functions.
	local x = self.spawnIcon.x + self.spawnIcon:GetWide() + 8;

	-- Set the position of the name and description.
	self.name:SetPos(x, 4);
	self.description:SetPos(x, 24);
	if (self.button) then
		self.button:SetPos(x, 47);
	end
end

-- Register the panel.
vgui.Register("Accessmenu Item", PANEL, "DPanel");

-- Register the panel.
--vgui.Register("cider_Container_Item", PANEL, "DPanel");
-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()

	-- Create the space used label.
	self.word = self.word or "argh"
	self.spaceUsed = vgui.Create("DLabel", self);
	self.spaceUsed:SetText(self.word);
	self.spaceUsed:SizeToContents();
	self.spaceUsed:SetTextColor( Color(255, 255, 255, 255) );
end

-- Called when the layout should be performed.
function PANEL:PerformLayout()

	-- Set the position of the label.
	self.spaceUsed:SetPos( (self:GetWide() / 2) - (self.spaceUsed:GetWide() / 2), 5 );
	self.spaceUsed:SetText(self.word);
	self.spaceUsed:SizeToContents();
end

-- Register the panel.
vgui.Register("Accessmenu Header", PANEL, "DPanel");
-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.noaccess			= vgui.Create("Accessmenu List",self)
	self.access				= vgui.Create("Accessmenu List",self)
	self.noaccess.action	= "Give"
	self.noaccess.name		= "Choices"
	self.access.action		= "Take"
	self.access.name		= "Access List"

end

-- Called when the layout should be performed.
function PANEL:PerformLayout()

	--self:SetSize(width,height)
	self:StretchToParent(0,22.5,0,0)
	--self:SetPos((ScrW() - width)/2,(ScrH() - height)/2)
	-- Set the position of both lists
	self.noaccess:SetPos(0, 0);
	self.access:SetPos(0 + self.noaccess:GetWide() + 4, 0);
end
-- Register the panel.
vgui.Register("Accessmenu Pane", PANEL)--, "DPanel");
-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle("Container");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(true);
	self:ShowCloseButton(false)
	-- Create the close button.
	self.close = vgui.Create("DButton", self);
	self.close:SetText("Close");
	self.close.DoClick = function()
		self:Close();
		self:Remove();

		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end
	self.sheets = vgui.Create("DPropertySheet",self)
	self.players = vgui.Create("Accessmenu Pane",self.sheets)
	self.jobs = vgui.Create("Accessmenu Pane",self.sheets)
	self.gangs = vgui.Create("Accessmenu Pane",self.sheets)
	self.sheets:AddSheet("Players",	self.players,nil,false,true,nil)
	self.sheets:AddSheet("Jobs",	self.jobs	,nil,false,true,nil)
	self.sheets:AddSheet("Gangs",	self.gangs	,nil,false,true,nil)
	self.texbox	= vgui.Create("DTextEntry",	self)
	self.setbut = vgui.Create("DButton",	self)
	self.setbut:SetText("Set Name")
	local function setName()
		val = self.texbox:GetValue()
		if not val or val == "" then return end
		RunConsoleCommand("cider", "entity", "name", val:sub(1,32));
		self.texbox:SetText("")
		self.texbox:KillFocus()
	end
	self.texbox.OnEnter = setName
	self.setbut.DoClick = setName
	self.selbut = vgui.Create("DButton",	self)
	self.selbut:SetText("Sell")
	self.selbut.DoClick = function()
		local menu = DermaMenu();
		
		-- Add an option for yes and no.
		menu:AddOption("No", function() end);
		menu:AddOption("Yes", function()
			RunConsoleCommand("cider", "door", "sell");
			accessmenu:Close();
			accessmenu:Remove();
			gui.EnableScreenClicker(false);
		end);
		
		-- Open the menu.
		menu:Open() ;
	end
	-- Capture the position of the local player.
	localPlayerPosition = LocalPlayer():GetPos();

end

-- Called when the layout should be performed.
function PANEL:PerformLayout()

	self:SetSize			(width,											height)
	self:SetPos				((ScrW() - width)/2,			   (ScrH() - height)/2)
	 self.close:SetSize		(48, 												16)
	self.selbut:SetSize		(48,												16)
	self.setbut:SetSize		(60,												16)
	self.texbox:SetSize		(self:GetWide()/ 4,									16)
	self.texbox:SetPos		(self:GetWide()/ 2 + 2, 							27)
	self.setbut:SetPos		(self:GetWide()/ 2 + 2 + self.texbox:GetWide() + 5,	27)
	self.selbut:SetPos		(self:GetWide() - self.selbut:GetWide() - 10,		27)
	self.close:SetPos		(self:GetWide() - self.close:GetWide() - 10,		3 )
	self.texbox:SetVisible	(false												  )
	self.setbut:SetVisible	(false												  )
	self.selbut:SetVisible	(false												  )
	if accessmenu.owned then
		if accessmenu.name then
			self.texbox:RequestFocus()
			self.texbox:SetVisible(true)
			self.setbut:SetVisible(true)
		end
		if accessmenu.sellable then
			self.selbut:SetVisible(true)
		end
	else
	end
--[[	self.label1:SetText"Change Name:"
	self.label1:SizeToContents()
	self.label1:SetTall(21)
	--self.label1:SetPaintBackground(false)
--]]
	self.sheets:SetPos(8, 25)
	self.sheets:StretchToParent(8,25,8,8)
	self.sheets:InvalidateLayout()
	--[[
	if CurTab then
		print(CurTab)
		accessmenu.sheets:SetActiveTab(CurTab)
	end
	--]]
	--[[
	for _,tab in pairs(self.sheets.Items) do
		tab.Tab:SetWide((self.sheets:GetWide()-5)/3)
	end
	self.sheets:InvalidateLayout()
	--]]
	-- Check if the local player's position is different from our captured one.
	if ( LocalPlayer():GetPos() ~= localPlayerPosition or !LocalPlayer():Alive() ) then
		self:Close();
		self:Remove();

		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end
	-- Perform the layout of the main frame.
	DFrame.PerformLayout(self);
end

-- Register the panel.
vgui.Register("Accessmenu", PANEL, "DFrame");--]]

local function psort(a, b)
	return a:Name() < b:Name();
end
local function tsort(a, b)
	return a.TeamID < b.TeamID;
end
local function gsort(a, b)
	return a.GangID < b.GangID;
end
local function UpdateContainer(decoded)
	if not accessmenu then return end
	--[[
	local tab = {}
	tab.tab = accessmenu.sheets:GetActiveTab()
	print(tab.tab)
	--]]
	accessmenu:SetTitle(decoded.title)
	local paccess = {}
	local taccess = {}
	local gaccess = {}
	local pnoaccess = {}
	local tnoaccess = {}
	local gnoaccess = {}
	for id, group in pairs(GM.Groups) do
		taccess[id] = {};
		gaccess[id] = {};
		paccess[id] = {};
		tnoaccess[id] = {};
		gnoaccess[id] = {};
		pnoaccess[id] = {};
		for _, team in pairs(group.Teams) do
			paccess[id][team.TeamID] = {};
			pnoaccess[id][team.TeamID] = {};
		end
	end
	local gyes, gno = {}, {};
	local done = {};
	local res;
	-- Get privilaged
	decoded.access[decoded.owner] = true;
	for key in pairs(decoded.access) do
		if type(key) == "Player" then
			res = key:GetTeam();
			table.insert(paccess[res.Group.GroupID][res.TeamID], key);
			done[key] = true;
		else
			local kind, id = string.match(key, "(.+): (.+)");
			--print(key, kind, id);
			id = tonumber(id);
			if (kind == "Team") then
				res = team.Get(id);
				table.insert(taccess[res.Group.GroupID], res);
			elseif (kind == "Group") then
				res = GM:GetGroup(id);
				--gaccess[res.GroupID][0] = res;
				gyes[res.GroupID] = res;
			elseif (kind == "Gang") then
				res = GM:GetGang(id);
				table.insert(gaccess[res.Group.GroupID], res);
			end
			done[res] = true;
		end
	end
	-- Get unprivilaged
	for _, ply in pairs(player.GetAll()) do
		if (not done[ply]) then
			res = ply:GetTeam();
			table.insert(paccess[res.Group.GroupID][res.TeamID], ply);
		end
	end
	for _, res in pairs(GM.Teams) do
		if (not done[res]) then
			table.insert(tnoaccess[res.Group.GroupID], res);
		end
	end
	for _, res in pairs(GM.Groups) do
		if (not done[res]) then
			--gnoaccess[res.GroupID][0] = res;
			gno[res.GroupID] = res;
		end		
	end
	for _, res in pairs(GM.Gangs) do
		if (not done[res]) then
			table.insert(gnoaccess[res.Group.GroupID], res);
		end
	end
	-- Sort tables
	for _, g in pairs(paccess) do
		for _, t in pairs(g) do
			table.sort(t, psort);
		end
	end
	-- Sort tables
	for _, g in pairs(pnoaccess) do
		for _, t in pairs(g) do
			table.sort(t, psort);
		end
	end
	for _, res in pairs(taccess) do
		table.sort(res, tsort);
	end
	for _, res in pairs(tnoaccess) do
		table.sort(res, tsort);
	end
	for _, res in pairs(gaccess) do
		table.sort(res, gsort);
	end
	for _, res in pairs(gnoaccess) do
		table.sort(res, gsort);
	end
	for id, res in pairs(gyes) do
		gaccess[id][0] = res;
	end
	for id, res in pairs(gno) do
		gnoaccess[id][0] = res;
	end
	-- Gief content
	accessmenu.players.noaccess.inventory	= pnoaccess
	accessmenu.players.access.inventory		= paccess
	accessmenu.jobs.noaccess.inventory		= tnoaccess
	accessmenu.jobs.access.inventory		= taccess
	accessmenu.gangs.noaccess.inventory		= gnoaccess
	accessmenu.gangs.access.inventory		= gaccess
	-- wedraww
	accessmenu.players.noaccess.updatePanel	= true
	accessmenu.players.access.updatePanel	= true
	accessmenu.jobs.noaccess.updatePanel	= true
	accessmenu.jobs.access.updatePanel		= true
	accessmenu.gangs.noaccess.updatePanel	= true
	accessmenu.gangs.access.updatePanel		= true
	-- who's whom.
	accessmenu.players.noaccess.isply		= true
	accessmenu.players.access.isply			= true
	accessmenu.jobs.noaccess.isteam			= true
	accessmenu.jobs.access.isteam			= true
	accessmenu.owned = tobool(decoded.owned)
	if accessmenu.owned then
		accessmenu.sellable = decoded.owned.sellable
		accessmenu.name = decoded.owned.name
	end
	accessmenu:InvalidateLayout()
	accessmenu.Buttoned = false
	--[[
	print(accessmenu.sheets.Items[1].Tab,tab.tab)
	PrintTable(accessmenu.sheets.Items)
	accessmenu.sheets:SetActiveTab(accessmenu.sheets.Items[2].Tab)
	accessmenu.sheets:SetActiveTab(tab.tab)
	--]]
	--[[
	print(accessmenu.sheets:GetActiveTab(),tab.tab)
	timer.Simple(1,accessmenu.sheets.SetActiveTab,accessmenu.sheets,tab.tab)
	--]]
	
end
function NewContainer( handle, id, encoded, decoded )
	--PrintTable(decoded)
	if accessmenu then accessmenu:Remove() end
	accessmenu = vgui.Create"Accessmenu"
	gui.EnableScreenClicker(true);
	accessmenu:MakePopup()
	UpdateContainer(decoded)
end
datastream.Hook( "Access Menu", NewContainer );
datastream.Hook( "Access Menu Update", function(handle, id, encoded, decoded)
	UpdateContainer(decoded)
end)
