--
-- "sv_inventory.lua"
-- ~ Applejack ~
--
cider.inventory = {};
util.AddNetworkString("cider_Inventory_Item")
function cider.inventory.update(player, id, amount, force)
	if (type(amount) ~= "number") then
		error("wat", 2);
	end
	local item = GM.Items[id];
	if (not item) then
		return false, "That is not a valid item!";
	elseif (not item.Size) then
		ErrorNoHalt("Uh, something broke here with item ", id, ".\n");
		PrintTable(item);
		return false, "shits broke cap'tan";
	elseif (not (amount < 1 or cider.inventory.canFit(player, item.Size * amount) or
		force)) then
		return false, "You do not have enough inventory space!";
	end --
	if item.onUpdate then
		local ret, msg = item:onUpdate(
			player, (player.cider._Inventory[id] or 0) + (amount or 0)
		)
		if ret ~= nil then -- Allow onUpdate to bypass the system
			return ret, msg
		end
	end
	player.cider._Inventory[id] = player.cider._Inventory[id] or 0
	if not force and item.max and player.cider._Inventory[id] + amount > item.max then
		return false, "You can't carry any more " .. item.plural .. "!"
	end
	player.cider._Inventory[id] = math.Clamp(
		player.cider._Inventory[id] + amount, 0, 2147483647
	)
	-- Check to see if we do not have any of this item now.
	if (player.cider._Inventory[id] <= 0) then
		if (amount > 0) then
			player.cider._Inventory[id] = amount;
		else
			player.cider._Inventory[id] = nil;
		end
		-- return true
	end
	-- Notify the player of the change
	net.Start("cider_Inventory_Item")
	net.WriteString(id)
	net.WriteInt(player.cider._Inventory[id] or 0, 32)
	net.Send(player)

	-- Return true because we updated the inventory successfully.
	return true;
end

-- Get the maximum amount of space a player has.
function cider.inventory.getMaximumSpace(player, inventory)
	local size = GM.Config["Inventory Size"];

	-- Loop through the player's inventory.
	for k, v in pairs(inventory or player.cider._Inventory) do
		item = GM.Items[k];
		if (item and item.Size < 0) then
			size = size + (item.Size * -v);
		end
	end

	-- Return the size.
	return size;
end

-- Get the size of a player's inventory.
function cider.inventory.getSize(player, inventory)
	local size = 0;

	-- Loop through the player's inventory.
	for k, v in pairs(inventory or player.cider._Inventory) do
		item = GM.Items[k];
		if (item and item.Size > 0) then
			size = size + (item.Size * v);
		end
	end

	-- Return the size.
	return size;
end

-- Check if a player can fit a specified size into their inventory.
function cider.inventory.canFit(player, size, inventory)
	return cider.inventory.getSize(player, inventory) + size <=
       		cider.inventory.getMaximumSpace(player, inventory) or size <= 0
end

local function playerInitInventory(player)
	if not IsValid(player) then
		return false
	elseif player.cider then
		for k, v in pairs(player.cider._Inventory) do
			cider.inventory.update(player, k, 0, true);
		end
	else
		return timer.Simple(1, playerInitInventory, player)
	end
end
hook.Add("PlayerInitialized", "Player Init Inventory", playerInitInventory)
