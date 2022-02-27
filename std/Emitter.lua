---@class std.Emitter
---@field listeners table
local Emitter = require('std.class').create('std.Emitter')

function Emitter:init() end

--- provides a way to throw an error if no error handlers are registered
---@param name string
---@param ... any
function Emitter:defaultHandler(name, ...) end

---@param name string
---@param callback function
function Emitter:on(name, callback) end

---@param name string
---@param callback function
function Emitter:once(name, callback) end

---@param name string
---@param ... any
function Emitter:emit(name, ...) end

---@param name string
---@param callback function
function Emitter:removeListener(name, callback) end

---@param name string
function Emitter:removeAllListeners(name) end

return Emitter
