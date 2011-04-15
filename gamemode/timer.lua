--[[
	~ Shared Timer Module ~
	~ Moonshine ~
--]]

local CurTime				= CurTime
local UnPredictedCurTime	= UnPredictedCurTime
local unpack				= unpack
local pairs					= pairs
local table					= table
local pcall					= pcall
local ErrorNoHalt			= ErrorNoHalt
local hook					= hook
local tostring				= tostring

--[[
	This is a rewrite of Garry's timer module.
	It's pretty good, but it occasionally produces minor errors,
	 which break all timers currently running.
	This will prevent it, and add a few of my own timer funcs.
--]]
oldtimer = timer
timer = {}

--[[ Enums ]]--
local KILLED	= -2
local PAUSED	= -1
local STOPPED	= 0
local RUNNING	= 1

--[[ Timer Holders ]]--
local timers			= {}
local simpletimers		= {}
local conditionaltimers = {}
local todeleten			= {}
local todeletec			= {}

--[[ Internal Functions ]]--
-- Get a timerr
local function getTimer(name)
	if timers[name] then
		return timers[name]
	elseif conditionaltimers[name] then
		return conditionaltimers[name]
	end
	return nil
end

--[[ Module Functions ]]--
--[[
	Desc: Checks if a timer exists
	Args: name
--]]
function timer.IsTimer(name)
	return getTimer(name) ~= nil
end

--[[
	Desc: Create a new timer, destroying any existing ones.
	Args: name, delay, repititons, function to call at the end, arguments.
--]]
function timer.Create(name,...)
	timer.Destroy(name,true)
	timer.Adjust(name,...)
	timer.Start(name)
end

--[[
	Desc: Start a timer from the beginning
	Args: Name
--]]
function timer.Start(name)
	local timer = getTimer(name)
	if not timer then return false end
	timer.n		 = 0
	timer.status = RUNNING
	timer.last	 = CurTime()
	return true
end

--[[
	Desc: Adjust a timer
	Args: name, delay, repititons, [function to call at the end], arguments.
--]]
function timer.Adjust(name,delay,reps,func,...)
	local arg = {...};
	local timer = getTimer(name)
	if not timer then
		timers[name] = {
			status = STOPPED;
		}
		timer = timers[name]
	elseif timer.failure then
		return timer.AdjustConditional(name,delay,reps,func,...)
	end
	if delay then
		timer.delay = delay
	end if reps then
		timer.reps 	= reps
	end if func then
		timer.func	= func
	end if #arg > 0 then
		timer.args	= arg;
	elseif not timer.args then
		timer.args = {};
	end
	return true
end

--[[
	Desc: Pause a running timer.
	Args: name
--]]
function timer.Pause(name)
	local timer = getTimer(name)
	if not timer or timer.status ~= RUNNING then return false end
	timer.diff = CurTime() - timer.last
	timer.status = PAUSED
	return true
end

--[[
	Desc: Resumes a paused timer.
	Args: name
--]]
function timer.UnPause(name)
	local timer = getTimer(name)
	if not timer or timer.status ~= PAUSED then return false end
	timer.diff = nil
	timer.status = RUNNING
	return true
end

--[[
	Desc: Toggles a timer's pause state.
	Args: name
--]]
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

--[[
	Desc: Stops a running or paused timer.
	Args: Name
--]]
function timer.Stop(name)
	local timer = getTimer(name)
	if not timer or timer.status == STOPPED then return false end
	timer.status = STOPPED
	--[[
	if timer.failure then
		timer.failure(unpack(table.Add(timer.args,{...})))
	end
	--]]
	return true
end

--[[
	Desc: Checks all timers and completes any tasks that need doing
	Args: None
--]]
local nextrep = 0 -- Fer the conditionals
function timer.Check()
	local time = CurTime()
	-- Delete unwanted timers before they can hurt again
	for _,name in pairs(todeleten) do
		timers[name] = nil
	end
	--[[ Normal Timers ]]--
	for name,data in pairs(timers) do
		if data.status == PAUSED then
			data.last = time - data.diff
		elseif data.status == RUNNING and data.last + data.delay <= time then
			data.last	= time
			data.n		= data.n + 1
			local res,err = pcall(data.func,unpack(data.args or {}))
			if not res then
				ErrorNoHalt("Error in timer '"..tostring(name).."': "..tostring(err).."\n")
			end
			if data.n >= data.reps and data.reps ~= 0 then
				timer.Stop(name)
			end
		end
	end
	--[[ Simple timers ]]--
	for id,data in pairs(simpletimers) do
		if data.fin <= time then
			local res, err = pcall(data.func,unpack(data.args))
			if not res then
				ErrorNoHalt("Timer Error: "..tostring(err).."\n")
			end
			simpletimers[id] = nil
		end
	end
	-- Delete unwanted conditional timers before they can be called.
	for _,name in pairs(todeletec) do
		conditionaltimers[name] = nil
	end
	-- Conditional timers are only called every 0.1 seconds.
	if nextrep > time then return end
	nextrep = time + 0.1
	--[[ Conditional Timers ]]--
	for name,data in pairs(conditionaltimers) do
		if data.status == RUNNING then
			data.n = data.n + 1
			local res,err = pcall(data.conditional,unpack(data.args))
			if not res then
				ErrorNoHalt("Error in conditional timer '"..tostring(name).."' conditional func: "..tostring(err).."\n")
			elseif err == false then
				local res,err = pcall(data.failure,unpack(data.args))
				if not res then
					ErrorNoHalt("Error in conditional timer '"..tostring(name).."' failure func: "..tostring(err).."\n")
				end
				timer.Stop(name)
			elseif err == "skip" then
				data.n = data.n - 1
			end
			if data.n >= data.reps then
				local res,err = pcall(data.success,unpack(data.args))
				if not res then
					ErrorNoHalt("Error in conditional timer '"..tostring(name).."' success func: "..tostring(err).."\n")
				end
				timer.Stop(name)
			end
		end
	end
end
hook.Add("Think","Moonshine Timer Checker",timer.Check);

--[[
	Desc: Destroy a timer, removing all traces of it.
	Args: name, [delete now]
	Note: If 'delete now' is not specified, the timer will be deleted on the next think.
--]]
function timer.Destroy(name,now)
	local timer = getTimer(name)
	if not timer then return false end
	if timer.failure then -- Conditional timer
		if now then
			conditionaltimers[name] = nil
		else -- This is to prevent various odd errors that occasionally pop up
			table.insert(todeletec,name)
		end
	else
		if now then
			timers[name] = nil
		else
			table.insert(todeleten,name)
		end
	end
	return true
end
timer.Remove = timer.Destroy;
--[[
	Desc: Create a simple "create and forget" timer
	Args: Delay, function, vararg...
--]]
function timer.Simple(delay,func,...)
	table.insert(simpletimers,{
		fin = UnPredictedCurTime() + delay;
		func = func;
		args = {...};
	})
	return true
end

--[[
	Desc: Create a conditional timer.
	Args: Name, Seconds, Condition function, Success function, Failure function, vararg...
	Note: The Conditional function will be called once every 0.1 seconds for Seconds seconds until it either returns false or the time runs out.
			If it returns false, the Failure function will be called and the timer will be stopped.
			If the time runs out, the Success function will be called.
			If it returns 'skip', 0.1 seconds will be added to the time remaining.
			The arguments passed at the end will be given to all functions.
			(Also note that the arguments are not in the definition. They are all required, however.)
--]]
function timer.Conditional(name,...)
	timer.Destroy(name,true)
	timer.AdjustConditional(name,...)
	timer.Start(name)
	return true
end

--[[
	Desc: Adjust a conditional timer.
	Args: Name, Seconds, [Condition function], [Success function], [Failure function], vararg...
--]]
function timer.AdjustConditional(name,seconds,conditional,success,failure,...)
	local timer = getTimer(name)
	if not timer then
		timer = {
			status = STOPPED,
		}
		conditionaltimers[name] = timer;
	end
	timer.reps				= math.Round(seconds*10)
	if conditional then
		timer.conditional	= conditional
	end if success then
		timer.success		= success
	end if failure then
		timer.failure		= failure
	end
	local arg = {...};
	if #arg > 0 then
		timer.args			= arg
	end
end

--[[
	Desc: Violates a conditional timer.
	Args: name, [vararg...]
	Note: This function will cause a conditional timer to act as if the condition function returned false.
			Additional argumenets passed will be passed to the failure function.
			Do not call this from a conditional timer, it will have unpredictable results.
--]]
function timer.Violate(name,...)
	local Timer = getTimer(name)
	if not Timer then return false end
	local res,err = pcall(Timer.failure,unpack(table.Add(Timer.args,{...})))
	if not res then
		error("Error violating timer '"..tostring(name).."': "..tostring(err),2)
	end
	timer.Stop(name)
	return true
end
