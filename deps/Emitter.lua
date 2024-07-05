---@class std.Emitter
---@field listeners table
local Emitter = import('class').create('std.Emitter')

function Emitter:init()
    error('not yet implemented')
end

--- provides a way to throw an error if no error handlers are registered
---@param name string
---@param ... any
function Emitter:defaultHandler(name, ...)
    error('not yet implemented')
end

---@param name string
---@param callback function
function Emitter:on(name, callback)
    error('not yet implemented')
end

---@param name string
---@param callback function
function Emitter:once(name, callback)
    error('not yet implemented')
end

---@param name string
---@param ... any
function Emitter:emit(name, ...)
    error('not yet implemented')
end

---@param name string
---@param callback function
function Emitter:removeListener(name, callback)
    error('not yet implemented')
end

---@param name string
function Emitter:removeAllListeners(name)
    error('not yet implemented')
end

return Emitter
