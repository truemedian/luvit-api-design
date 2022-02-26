---@class std.Process
---@field argv string[]
---@field pid integer
local Process = {}

---@return std.Process
function Process.init() end

---@return path_t
function Process.cwd() end

---@param pid integer
---@param signal string
function Process.kill(pid, signal) end

---@param code integer
function Process.exit(code) end

---@return { rss: number, heap: number }
function Process.memoryUsage() end

---@return { user: number, system: number }
function Process.cpuUsage() end

return Process
