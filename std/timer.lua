---@class std.timer
local timer = {}

---@alias uv_timer_t userdata

---@param delay number
---@param thread? thread
---@return uv_timer_t
---@error nil, string, string
function timer.sleep(delay, thread) end

---@param delay number
---@param callback function
---@param ... any
---@return uv_timer_t
---@error nil, string, string
function timer.delay(delay, callback, ...) end

---@param delay number
---@param callback function
---@param ... any
---@return uv_timer_t
---@error nil, string, string
function timer.periodically(delay, callback, ...) end

---@param callback function
---@param ... any
---@error nil, string, string
function timer.immediately(callback, ...) end

---@param timer_t uv_timer_t
function timer.clear(timer_t) end

return timer
