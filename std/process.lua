
---@class processlib
---@field argv string[]
---@field pid pid
local process = {}

---@alias pid integer

---@return path
function process.cwd() end

---@param pid pid
---@param signal string
function process.kill(pid, signal) end

---@param code integer
function process.exit(code) end

---@return { rss: number, heap: number }
function process.memoryUsage() end

---@return { user: number, system: number }
function process.cpuUsage() end

return process
