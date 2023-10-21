local uv = require 'uv'
local utils = require 'utils'

---@class std.timer
local timer = {}

---@alias uv_timer_t userdata

---Yield the current coroutine for at least `delay` milliseconds.
---@param delay number
function timer.sleep(delay)
    local thread = coroutine.running()
    local timer_obj = uv.new_timer()
    uv.timer_start(timer_obj, delay, 0, function()
        uv.timer_stop(timer_obj)
        uv.close(timer_obj)
        return utils.assertResume(thread)
    end)
    return coroutine.yield()
end

---Yield the current coroutine until the next event loop tick.
function timer.tick()
    local thread = coroutine.running()
    timer.immediately(utils.assertResume, thread)
    return coroutine.yield()
end

---Call `callback` after at least `delay` milliseconds.
---@param delay number
---@param callback fun(...: any)
---@param ... any Arguments to pass to `callback`
---@return uv_timer_t
function timer.delay(delay, callback, ...)
    local timer_obj = uv.new_timer()
    local args = { ... }
    local len = select('#', ...)
    uv.timer_start(timer_obj, delay, 0, function()
        uv.timer_stop(timer_obj)
        uv.close(timer_obj)
        callback(unpack(args, 1, len))
    end)
    return timer_obj
end

---Call `callback` every at least `delay` milliseconds.
---@param delay number
---@param callback fun(...: any)
---@param ... any Arguments to pass to `callback`
---@return uv_timer_t
function timer.periodically(delay, callback, ...)
    local timer_obj = uv.new_timer()
    local args = { ... }
    local len = select('#', ...)
    uv.timer_start(timer_obj, delay, delay, function()
        callback(unpack(args, 1, len))
    end)
    return timer_obj
end

local checker = uv.new_check()
local idler = uv.new_idle()
local immediateQueue = {}

local function onLoopTick()
	local oldQueue = immediateQueue
	immediateQueue = {}
	for i = 1, #oldQueue do
		oldQueue[i]()
	end

	-- Stop tick handles if the queue is (still) empty
	if #immediateQueue == 0 then
		uv.check_stop(checker)
		uv.idle_stop(idler)
	end
end

---Call `callback` on the next event loop tick.
---@param callback fun(...: any)
---@param ... any Arguments to pass to `callback`
function timer.immediately(callback, ...)
	-- If the queue is empty, handles are stopped; start them
	if #immediateQueue == 0 then
		uv.check_start(checker, onLoopTick)
		uv.idle_start(idler, onLoopTick)
	end

	local args = { ... }
	local len = select("#", ...)
	table.insert(immediateQueue, function()
		callback(unpack(args, 1, len))
	end)
end

---Stop and close a running timer handle.
---@param timer_obj uv_timer_t
function timer.clear(timer_obj)
    if uv.is_closing(timer_obj) then return end
    uv.timer_stop(timer_obj)
    uv.close(timer_obj)
end

return timer
