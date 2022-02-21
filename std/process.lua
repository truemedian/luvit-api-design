---@class processlib
---@field argv string[]
---@field pid pid_t
local process = {}

---@alias pid_t integer

---@return path_t
function process.cwd() end

---@param pid pid_t
---@param signal string
function process.kill(pid, signal) end

---@param code integer
function process.exit(code) end

---@return { rss: number, heap: number }
function process.memoryUsage() end

---@return { user: number, system: number }
function process.cpuUsage() end

return process
