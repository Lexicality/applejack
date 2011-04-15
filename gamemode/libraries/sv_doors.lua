--[[
	~ Serverside Doors Library ~
	~ Moonshine ~
--]]

---
-- Used for saving and restoring the ownership of doors built in to a map using the SQLite db.
doors = {}

local function check(door)
	if (not IsValid(door)) then
		error("Tried to use a NULL entity!", 3);
	end
end

---
-- Loads data for a single door from the SQLite db
-- @param door The door entity to load
function doors.Load(door)
	check(door)
	
end

---
-- Saves a door's data to the SQLite db
-- @param door The door entity to save
function doors.Save(door)
	check(door)
	
end

---
-- Changes the state of a status of a door
-- @param door The door entity to change
-- @param status The OBJ_ enum status to change
-- @param state The state to set it to
function doors.ChangeStatus(door, status, state)
	check(door)
	door.statuses[status] = state;
end

---
-- Gets the stored state of a door
-- @param door The door entity to get the statuses of
function doors.GetStatuses(door)
	check(door)
	return door.statues;
end

---
-- Gets a the state of a specific status of a door
-- @param door The door entity to get the status of
-- @param status The OBJ_ status to get
function doors.GetStatus(door, status)
	check(door)
	return door.statuses[status];
end