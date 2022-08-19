local uv = require 'uv'

---@class std.timer
local timer = {}

---@alias uv_timer_t userdata

local function assertResume(thread, ...)
    local success, err = coroutine.resume(thread, ...)
    if not success then
        error(debug.traceback(thread, err), 0)
    end
end

---@param delay number
---@return uv_timer_t
---@error nil, string, string
function timer.sleep(delay)
    local thread = coroutine.running()
    local timer_obj = uv.new_timer()
    uv.timer_start(timer_obj, delay, 0, function()
        uv.timer_stop(timer_obj)
        uv.close(timer_obj)
        return assertResume(thread)
    end)
    return coroutine.yield()
end

---@param delay number
---@param callback fun(...: any)
---@param ... any
---@return uv_timer_t
---@error nil, string, string
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

---@param delay number
---@param callback fun(...: any)
---@param ... any
---@return uv_timer_t
---@error nil, string, string
function timer.periodically(delay, callback, ...)
    local timer_obj = uv.new_timer()
    local args = { ... }
    local len = select('#', ...)
    uv.timer_start(timer_obj, delay, delay, function()
        callback(unpack(args, 1, len))
    end)
    return timer_obj
end

---@param callback fun(...: any)
---@param ... any
---@error nil, string, string
function timer.immediately(callback, ...) end

---@param timer_obj uv_timer_t
function timer.clear(timer_obj)
    if uv.is_closing(timer_obj) then return end
    uv.timer_stop(timer_obj)
    uv.close(timer_obj)
end

return timer
