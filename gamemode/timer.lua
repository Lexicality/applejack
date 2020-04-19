--
-- ~ Shared Timer Module ~
-- ~ Moonshine ~
--
local CurTime = CurTime
local UnPredictedCurTime = UnPredictedCurTime
local unpack = unpack
local pairs = pairs
local table = table
local pcall = pcall
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local tostring = tostring

-- This is a rewrite of Garry's timer module.
-- It's pretty good, but it occasionally produces minor errors, which break all
--  timers currently running.
-- This will prevent it, and add a few of my own timer funcs.
oldtimer = timer
timer = {}

-- Enums
local KILLED = -2
local PAUSED = -1
local STOPPED = 0
local RUNNING = 1

-- Timer Holders
local timers = {}
local simpletimers = {}
local conditionaltimers = {}
local todeleten = {}
local todeletec = {}

-- Internal Functions

---
-- Get a timerr
local function getTimer(name)
	if timers[name] then
		return timers[name]
	elseif conditionaltimers[name] then
		return conditionaltimers[name]
	end
	return nil
end

-- Module Functions

---
--- Checks if a timer exists
--- @param name string
--- @return boolean
function timer.IsTimer(name)
	return getTimer(name) ~= nil
end

---
--- Create a new timer, destroying any existing ones.
--- @param name string
--- @param delay number
--- @param reps integer
--- @param func function @Callback to call
--- @vararg any @Args to pass to func
function timer.Create(name, delay, reps, func, ...)
	timer.Destroy(name, true)
	timer.Adjust(name, delay, reps, func, ...)
	timer.Start(name)
end

---
--- Start a timer from the beginning
--- @param name string
--- @return boolean
function timer.Start(name)
	local timer = getTimer(name)
	if not timer then
		return false
	end
	timer.n = 0
	timer.status = RUNNING
	timer.last = CurTime()
	return true
end

---
--- Adjust a timer
--- @param name string
--- @param delay number
--- @param reps integer
--- @param func function @Callback to call
--- @vararg any @Args to pass to func
--- @return boolean
function timer.Adjust(name, delay, reps, func, ...)
	local arg = {...};
	local timer = getTimer(name)
	if not timer then
		timers[name] = {status = STOPPED}
		timer = timers[name]
	elseif timer.failure then
		return timer.AdjustConditional(name, delay, reps, func, ...)
	end
	if delay then
		timer.delay = delay
	end
	if reps then
		timer.reps = reps
	end
	if func then
		timer.func = func
	end
	if #arg > 0 then
		timer.args = arg;
	elseif not timer.args then
		timer.args = {};
	end
	return true
end

---
--- Pause a running timer.
--- @param name string
--- @return boolean
function timer.Pause(name)
	local timer = getTimer(name)
	if not timer or timer.status ~= RUNNING then
		return false
	end
	timer.diff = CurTime() - timer.last
	timer.status = PAUSED
	return true
end

---
--- Resumes a paused timer.
--- @param name string
--- @return boolean
function timer.UnPause(name)
	local timer = getTimer(name)
	if not timer or timer.status ~= PAUSED then
		return false
	end
	timer.diff = nil
	timer.status = RUNNING
	return true
end

---
--- Toggles a timer's pause state.
--- @param name string
--- @return boolean
function timer.Toggle(name)
	local timer = getTimer(name)
	if timer then
		if timer.status == PAUSED then
			return timer.UnPause(name)
		elseif timer.status == RUNNING then
			return timer.Pause(name)
		end
	end
	return false
end

---
--- Stops a running or paused timer.
--- @param name string
--- @return boolean
function timer.Stop(name)
	local timer = getTimer(name)
	if not timer or timer.status == STOPPED then
		return false
	end
	timer.status = STOPPED
	-- if timer.failure then
	-- 	timer.failure(unpack(table.Add(timer.args,{...})))
	-- end
	return true
end

---
--- Checks all timers and completes any tasks that need doing
local nextrep = 0 -- Fer the conditionals
function timer.Check()
	local time = CurTime()
	-- Delete unwanted timers before they can hurt again
	for _, name in pairs(todeleten) do
		timers[name] = nil
	end
	-- Normal Timers
	for name, data in pairs(timers) do
		if data.status == PAUSED then
			data.last = time - data.diff
		elseif data.status == RUNNING and data.last + data.delay <= time then
			data.last = time
			data.n = data.n + 1
			local res, err = pcall(data.func, unpack(data.args or {}))
			if not res then
				ErrorNoHalt(
					"Error in timer '" .. tostring(name) .. "': " .. tostring(err) .. "\n"
				)
			end
			if data.n >= data.reps and data.reps ~= 0 then
				timer.Stop(name)
			end
		end
	end
	-- Simple timers
	for id, data in pairs(simpletimers) do
		if data.fin <= time then
			local res, err = pcall(data.func, unpack(data.args))
			if not res then
				ErrorNoHalt("Timer Error: " .. tostring(err) .. "\n")
			end
			simpletimers[id] = nil
		end
	end
	-- Delete unwanted conditional timers before they can be called.
	for _, name in pairs(todeletec) do
		conditionaltimers[name] = nil
	end
	-- Conditional timers are only called every 0.1 seconds.
	if nextrep > time then
		return
	end
	nextrep = time + 0.1
	-- Conditional Timers
	for name, data in pairs(conditionaltimers) do
		if data.status == RUNNING then
			data.n = data.n + 1
			local res, err = pcall(data.conditional, unpack(data.args))
			if not res then
				ErrorNoHalt(


						"Error in conditional timer '" .. tostring(name) .. "' conditional func: " ..
							tostring(err) .. "\n"
				)
			elseif err == false then
				local res, err = pcall(data.failure, unpack(data.args))
				if not res then
					ErrorNoHalt(
						"Error in conditional timer '" .. tostring(name) .. "' failure func: " ..
							tostring(err) .. "\n"
					)
				end
				timer.Stop(name)
			elseif err == "skip" then
				data.n = data.n - 1
			end
			if data.n >= data.reps then
				local res, err = pcall(data.success, unpack(data.args))
				if not res then
					ErrorNoHalt(
						"Error in conditional timer '" .. tostring(name) .. "' success func: " ..
							tostring(err) .. "\n"
					)
				end
				timer.Stop(name)
			end
		end
	end
end
hook.Add("Think", "Moonshine Timer Checker", timer.Check);

---
--- Destroy a timer, removing all traces of it.
--- @param name string
--- @param now boolean @delete immidately or on next think
--- @return boolean
function timer.Destroy(name, now)
	local timer = getTimer(name)
	if not timer then
		return false
	end
	if timer.failure then -- Conditional timer
		if now then
			conditionaltimers[name] = nil
		else -- This is to prevent various odd errors that occasionally pop up
			table.insert(todeletec, name)
		end
	else
		if now then
			timers[name] = nil
		else
			table.insert(todeleten, name)
		end
	end
	return true
end
timer.Remove = timer.Destroy;

---
--- Create a simple "create and forget" timer
--- @param delay number
--- @param func function
--- @vararg any
function timer.Simple(delay, func, ...)
	table.insert(
		simpletimers, {fin = UnPredictedCurTime() + delay, func = func, args = {...}}
	)
	return true
end

--- Create a conditional timer.
--- Note: The Conditional function will be called once every 0.1 seconds for Seconds seconds until it either returns false or the time runs out.
--- 		If it returns false, the Failure function will be called and the timer will be stopped.
--- 		If the time runs out, the Success function will be called.
--- 		If it returns 'skip', 0.1 seconds will be added to the time remaining.
--- 		The arguments passed at the end will be given to all functions.
--- @param name string
--- @param seconds number
--- @param conditional function
--- @param success function
--- @param failure function
--- @vararg any
function timer.Conditional(name, seconds, conditional, success, failure, ...)
	timer.Destroy(name, true)
	timer.AdjustConditional(name, seconds, conditional, success, failure, ...)
	timer.Start(name)
	return true
end

---
--- Adjust a conditional timer.
--- @param name string
--- @param seconds number
--- @param conditional function
--- @param success function
--- @param failure function
--- @vararg any
function timer.AdjustConditional(
	name, seconds, conditional, success, failure, ...
)
	local timer = getTimer(name)
	if not timer then
		timer = {status = STOPPED}
		conditionaltimers[name] = timer;
	end
	timer.reps = math.Round(seconds * 10)
	if conditional then
		timer.conditional = conditional
	end
	if success then
		timer.success = success
	end
	if failure then
		timer.failure = failure
	end
	local arg = {...};
	if #arg > 0 then
		timer.args = arg
	end
end

---
--- Violates a conditional timer.
-- Args: name, [vararg...]
--- Note:
---  This function will cause a conditional timer to act as if the condition
---   function returned false.
---  Do not call this from a conditional timer, it will have unpredictable
---   results.
--- @param name string
--- @vararg any @Arguments to pass to the failure function
function timer.Violate(name, ...)
	local Timer = getTimer(name)
	if not Timer then
		return false
	end
	local res, err = pcall(Timer.failure, unpack(table.Add(Timer.args, {...})))
	if not res then
		error("Error violating timer '" .. tostring(name) .. "': " .. tostring(err), 2)
	end
	timer.Stop(name)
	return true
end
