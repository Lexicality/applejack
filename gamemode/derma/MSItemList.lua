--
-- ~ Player List ~
-- ~ Moonshine ~
--
local vguiItemPanel;
local PANEL = {};

AccessorFunc(PANEL, "m_fItemFunc", "Itemfunction");
AccessorFunc(PANEL, "m_fSortFunc", "SortFunction");
AccessorFunc(PANEL, "m_fCompareFunc", "CompareFunction");

PANEL.m_fItemFunc = nil; -- Cause an error if this function isn't set
PANEL.m_fSortFunc = nil; -- Don't sort if this function isn't set
PANEL.m_fCompareFunc = function(a, b)
	return a == b;
end; -- Basic equality.

function PANEL:Init()
	self.BaseClass.Init(self);
	self:Clear();
	self:SetPadding(2);
	self:SetSpacing(3);
	self:EnableVerticalScrollbar();
end

local function categorySortFunc(a, b)
	a, b = a.CategoryData, b.CategoryData;
	return a.Weight < b.Weight or a.Name < b.Name;
end
local itemSortFunc;

-- Override the automatic AccessorFunc
function PANEL:SetSortFunction(func)
	self.m_fSortFunc = func;
	if (not self.m_fSortFunc) then
		itemSortFunc = nil;
	else
		local f = self.m_fSortFunc;
		itemSortFunc = function(a, b)
			if (not (a and b) and (a.Item and b.Item)) then
				return false;
			else
				return f(a.Item, b.Item);
			end
		end
	end
end

PANEL._CategoryData = {Name = "/", Path = "", SortWeight = -math.huge}

function PANEL:Clear(...)
	self._Categories = {};
	self._Items = {};
	self.BaseClass.Clear(self, ...);
end

do
	local function doError(PanelList, ItemList, iscategory)
		-- Error spamming time!
		local msg = Msg
		Msg = ErrorNoHalt;
		local what, into;
		if (iscategory) then
			what = "categories";
			into = "item category";
		else
			what = "items";
			into = "category set";
		end
		Msg("Attempted to load ", what, " into an existing ", into, "!\n");
		Msg("We're in category '", tostring(PanelList._CategoryData.Path), "', ");
		Msg("which currently has ");
		if (iscategory) then
			Msg(table.Count(PanelList._Items), " items");
		else
			Msg(table.Count(PanelList._Categories), " categories");
		end
		Msg(" in it.\n");
		Msg("The offending insert table is: \n");
		PrintTable(ItemList);
		Msg = msg;
	end

	local function loadCategories(self, PanelList, ItemList)
		-- Make sure there actually is something in the list
		if (not next(ItemList)) then
			return;
		end
		-- Make sure we're not about to bugger everything up
		if (PanelList._ItemContainer) then
			doError(PanelList, ItemList, true);
			return;
		end
		PanelList._CategoryContainer = true;
		local CategoryList = {};
		for CategoryName, SubItemList in pairs(ItemList) do
			local Info = {
				Name = CategoryName,
				Weight = SubItemList.SortWeight or 0,
				ItemList = SubItemList,
				Path = PanelList._CategoryData.Path .. "/" .. CategoryName,
				Parent = PanelList,
			}
			SubItemList.SortWeight = nil;
			table.insert(CategoryList, Info);
		end

		for _, CategoryData in pairs(CategoryList) do
			local SubPanelList = PanelList._Categories[CategoryData.Name];
			if (not SubPanelList) then
				local SubHeader = vuil.Create("DCollapsableCategory", PanelList);
				SubPanelList = vgui.Create("MSDPanelList", SubHeader);
				SubPanelList:SetPadding(2);
				SubPanelList:SetSpacing(3);
				SubPanelList:SetAutoSize(true);
				SubPanelList._CategoryData = CategoryData;
				SubPanelList._Categories = {};
				SubPanelList._Items = {};

				SubHeader:SetText(CategoryData.Name);
				SubHeader:SetSize(PanelList:GetWide(), 50) -- 'parrently this has to be 50.
				SubHeader:SetContents(SubPanelList);
				SubHeader._CategoryData = CategoryData;

				PanelList:AddItem(SubHeader);
				PanelList._Categories[CategoryData.Name] = SubPanelList;
			end
			self:RecursiveLoad(SubPanelList, CategoryData.ItemList);
		end
		PanelList:SortByFunction(categorySortFunc);
	end

	local function loadItems(self, PanelList, ItemList)
		-- Make sure we're not about to bugger everything up
		if (PanelList._CategoryContainer) then
			doError(PanelList, ItemList, false);
			return;
		end
		PanelList._ItemContainer = true;
		for _, Item in ipairs(ItemList) do
			local ItemPanel = vgui.CreateFromTable(vguiItemPanel, PanelList);
			ItemPanel:SetItemFunction(self.m_fItemFunc);
			ItemPanel:SetItem(Item);
			PanelList:AddItem(ItemPanel);
			PanelList._Items[Item] = ItemPanel;
		end
		if (itemSortFunc) then
			PanelList:SortByFunction(itemSortFunc);
		end
	end

	function PANEL:RecursiveLoad(PanelList, ItemList)
		if (#ItemList == 0) then
			loadCategories(self, PanelList, ItemList);
		else
			loadItems(self, PanelList, ItemList);
		end
	end
end

do
	local catset = "category set";
	local itemcat = "item category";
	local function doError(PanelList, ItemList, iscategory)
		-- Error spamming time!
		local msg = Msg
		Msg = ErrorNoHalt;
		local is, isnt;
		if (iscategory) then
			is = itemcat;
			isnt = catset;
		else
			isnt = itemcat;
			is = catset;
		end
		Msg(
			"Attempted to treat a " .. is .. " as a " .. isnt ..
				" in the recurisve remover!\n"
		);
		Msg("We're in category '", tostring(PanelList._CategoryData.Path), "', ");
		Msg("which currently has ");
		if (iscategory) then
			Msg(table.Count(PanelList._Items), " items");
		else
			Msg(table.Count(PanelList._Categories), " categories");
		end
		Msg(" in it.\n");
		Msg("The offending remove table is: \n");
		PrintTable(ItemList);
		Msg = msg;
	end

	local function compitem(self, list, item)
		for key, value in pairs(list) do
			if (self.m_fCompareFunc(item, key)) then
				return value;
			end
		end
	end

	local function delCategories(self, PanelList, ItemList)
		-- Make sure there actually is something in the list
		if (not next(ItemList)) then
			return;
		end
		-- Make sure we're not about to bugger everything up
		if (PanelList._ItemContainer) then
			doError(PanelList, ItemList, true);
			return;
		end
		for CategoryName, SubItemList in pairs(ItemList) do
			local SubPanelList = PanelList._Categories[CategoryData.Name];
			if (SubPanelList) then
				self:RecursiveDelete(SubPanelList, SubItemList);
			end
		end
	end

	local function delItems(self, PanelList, ItemList)
		-- Make sure we're not about to bugger everything up
		if (PanelList._CategoryContainer) then
			doError(PanelList, ItemList, false);
			return;
		end
		for _, item in ipairs(ItemList) do
			local panel = compitem(self, PanelList._Items, item);
			if (panel) then
				PanelList:Remove(panel);
			end
		end
		if (itemSortFunc) then
			PanelList:SortByFunction(itemSortFunc);
		end
		if (#PanelList:GetItems() == 0) then
			local parent = PanelList._CategoryData;
			if (IsValid(parent)) then
				parent:RemoveItem(PanelList:GetParent());
			end
		end
	end

	function PANEL:RecursiveDelete(PanelList, ItemList)
		assert(
			PanelList._CategoryData, "No category data in " .. tostring(PanelList) .. "!"
		);
		if (#ItemList == 0) then
			delCategories(self, PanelList, ItemList);
		else
			delItems(self, PanelList, ItemList);
		end
	end
end

---
-- Recursively loads headers so you can have a multi-level list
-- @usage tab should be either a table of numerically indexed 'items' (AKA anything),
--         or a string indexed table of tables which have the same format as the parent.
--        This allows you to have potentially unlimited levels of DCollapsableCategories,
--         though for sanity's sake I suggest no more than 3.
--        This does not support mixed headers and entries. A DCollapsableCategory can have
--         either headers or items in it. Using both will result in undefined behaviour.
-- @param list The table with the entries to add
function PANEL:SetItems(list)
	if (not self.m_fItemFunc) then
		error("Tried to set items without an item function!", 2);
	end
	-- Wipe any existing items to make way for the new
	self:Clear(true);
	self:RecursiveLoad(self, list);
	self:InvalidateLayout(true);
end

---
-- Adds or removes individual items without resetting the list.
-- Items must be in the same structure as they were added in or it won't work
-- You probably need to set a compare function prior to trying to remove anything
-- @param delta A table containing two entries: Add and Remove, both of which are tables of the same strucutre as SetItems accepts.
function PANEL:DeltaUpdate(delta)
	if (delta.Add) then
		-- RecursiveLoad is robust enough to deal with this no trouble
		self:RecursiveLoad(self, delta.Add);
	end
	if (delta.Remove) then
		self:RecursiveDelete(self, delta.Remove);
	end
	self:InvalidateLayout(true);
end

derma.DefineControl(
	"MSItemList", "Container for Moonshine object lists", PANEL, "MSDPanelList"
);

--
--
-- Item
--
--

local PANEL = {};

AccessorFunc(PANEL, "m_fItemFunc", "ItemFunction");

PANEL.m_tButtons = {};

function PANEL:Init()
	self.m_pPortrait = vgui.Create("Spawnicon", self);
	self.m_pName = vgui.Create("DLabel", self); -- TODO: Work out how to make this bold
	self.m_pLabel = vgui.Create("DLabel", self);
end

function PANEL:SetPortrait(model)
	self.m_pPortrait:SetModel(model);
end

function PANEL:SetDescription(str)
	self.m_pLabel:SetText(str);
end

function PANEL:SetName(str)
	self.m_pName:SetText(str);
end

local function dbuttonpress(btn)
	btn.m_fCallback(btn.m_tItem);
end
function PANEL:AddButton(str, func)
	local btn = vgui.Create("DButton", self);
	btn:SetText(str);
	btn.DoClick = dbuttonpress;
	btn.m_fCallback = func;
	btn.m_tItem = self.Item;
	table.insert(self.m_tbuttons, btn);
	return btn;
end

function PANEL:PerformLayout()
	self.m_pName:SizeToContents();
	-- TODO: Work out how word-wrap work
	self.m_pDecsription:SizeToContents();
	local x, y = 4, 5
	-- Positions
	self.m_pPortrait:SetPos(x, y);
	x = x + self.m_pPortrait:GetWide() + 8;
	-- TODO: y should probably be worked out not set like this
	y = 4;
	self.m_pName:SetPos(x, y)
	y = 24;
	self.m_pDescription:SetPos(x, y);
	y = 47;
	for _, btn in pairs(self.m_tButtons) do
		btn:SetPos(x, y);
		x = x + btn:GetWide();
	end
end

function PANEL:SetItem(item)
	self.Item = item;
	self:m_fItemFunc(item);
end

vguiItemPanel = vgui.RegisterTable(PANEL, "DPanel");
