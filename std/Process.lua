---@class processlib
---@field argv string[]
---@field pid pid_t
local Process = {}

---@alias pid_t integer

---@return path_t
function Process.cwd() end

---@param pid pid_t
---@param signal string
function Process.kill(pid, signal) end

---@param code integer
function Process.exit(code) end

---@return { rss: number, heap: number }
function Process.memoryUsage() end

---@return { user: number, system: number }
function Process.cpuUsage() end

return Process
