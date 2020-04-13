--
-- ~ Item Metatable (shared) ~
-- ~ Applejack ~
--

---
-- The shared item metatable
-- @name meta
-- @class table
local meta = _R.Item;
if (not meta) then
	ErrorNoHalt("Applejack: Error setting up shared item metatable - Item metatable does not exist!");
	return
end


---
-- Derives the item from the base supplied. Any unset fields on the item that are set on the
--  base will be assigned from it.
-- This is necessary for bases inside plugins that wish to pre-derive themselves from existing
--  bases, since they can't just include the files like gamemode root ones do.
-- @param id The UniqueID of the item to derive from.
function meta:Derive(id)
	for k,v in pairs(GM.Items[id] or {}) do
		if (self[k] == nil) then
			self[k] = v;
		else
		end
	end
end

---
-- Internal: Registers a populated item table.
function meta:Register()
	if (not self.UniqueID) then
		ErrorNoHalt("Item with no uniqueID registered!\nDumping table:\n");
		-- WARNING: DIRTY HACK TIME
		msg = Msg;
		Msg = ErrorNoHalt;
		PrintTable(self);
		Msg = msg;
		-- END OF DIRTY HACK
		return false;
	end
	if (self.Base) then
		if (type(self.Base) == "table") then
			for _,id in ipairs(self.base) do
				self:Derive(id);
			end
		else
			self:Derive(self.Base);
		end
	end
	if (self.Model) then
		util.PrecacheModel(self.Model);
	end
	GM.Items[self.UniqueID] = self;
	if (SERVER) then
		umsg.PoolString(self.UniqueID);
	end
end
