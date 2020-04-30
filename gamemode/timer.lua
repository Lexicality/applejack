--
-- You ever get so conceited you write your own timer module?
-- ~ Moonshine ~
--
if not timer.oCreate then
	timer.oCreate = timer.Create
end
if not timer.oSimple then
	timer.oSimple = timer.Simple
end

---
--- Create a new timer, destroying any existing ones.
--- @param name string
--- @param delay number
--- @param reps integer
--- @param func function @Callback to call
--- @vararg any @Args to pass to func
function timer.Create(name, delay, reps, func, ...)
	local args = {...}
	if #args == 0 then
		timer.oCreate(name, delay, reps, func)
	else
		timer.oCreate(
			name, delay, reps, function()
				func(unpack(args))
			end
		)
	end
end

---
--- Create a simple "create and forget" timer
--- @param delay number
--- @param func function
--- @vararg any
function timer.Simple(delay, func, ...)
	local args = {...}
	if #args == 0 then
		timer.oSimple(delay, func)
	else
		timer.oSimple(
			delay, function()
				func(unpack(args))
			end
		)
	end
end

local function conditionalThink(name, data)
	data.n = data.n + 1
	local res, err = pcall(data.conditional, unpack(data.args))
	if not res then
		ErrorNoHalt(
			"Error in conditional timer '", tostring(name), "' conditional func: ",
			tostring(err), "\n"
		)
	elseif err == false then
		timer.Remove(name)
		data.failure(unpack(data.args))
	elseif err == "skip" then
		data.n = data.n - 1
	end
	if data.n >= data.reps then
		timer.Remove(name)
		data.success(unpack(data.args))
	end
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
	timer._conditionalTimers = timer._conditionalTimers or {}
	timer._conditionalTimers[name] = {n = 0}
	timer.Create(
		name, 0.1, 0, function()
			conditionalThink(name, timer._conditionalTimers[name])
		end
	)
	timer.AdjustConditional(name, seconds, conditional, success, failure, ...)
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
	if not timer.Exists(name) then
		return;
	end
	timer._conditionalTimers = timer._conditionalTimers or {}
	local data = timer._conditionalTimers[name]
	if not data then
		return
	end
	data.reps = math.Round(seconds * 10)
	data.conditional = conditional
	data.success = success
	data.failure = failure
	data.args = {...};
end

---
--- Cause a conditional timer to act like the condition failed
--- @param name string
function timer.Violate(name)
	if not timer.Exists(name) then
		return;
	end
	timer.Remove(name)

	timer._conditionalTimers = timer._conditionalTimers or {}
	local data = timer._conditionalTimers[name]
	if not data then
		return
	end

	data.failure(unpack(data.args))
end
