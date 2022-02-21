---@class timerlib
local timer = {}

---@alias uv_timer_t userdata

---@param delay number
---@param thread? thread
---@return uv_timer_t
function timer.sleep(delay, thread) end

---@param delay number
---@param callback function
---@param ... any
---@return uv_timer_t
function timer.setTimeout(delay, callback, ...) end

---@param delay number
---@param callback function
---@param ... any
---@return uv_timer_t
function timer.setInterval(delay, callback, ...) end

---@param timer_t uv_timer_t
function timer.clearInterval(timer_t) end

timer.clearTimeout = timer.clearInterval

---@param callback function
---@param ... any
function timer.setImmediate(callback, ...) end

return timer
