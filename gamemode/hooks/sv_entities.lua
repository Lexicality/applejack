--
-- ~ Serveride Entity Hooks ~
-- ~ Applejack ~
--

---
-- @name GM
-- @class table
-- @description The gamemode table.
local GM = GM;

---
-- Called when the owner of an en entity is set.
-- Currently very few things actaully call this even though more should.
-- The doors plugin uses this to memorise owners for doors on the map.
-- @param ent The entity whose owner has just been set.
-- @param owner The new owner. This is either a nil (no owner), player, or a Team/Group/Gang struct.
function GM:EntityOwnerSet(ent, owner)
	--
end
