---@class std.process
local process = {}

---@return integer
function process.getPid() end

---@return path_t
function process.getCwd() end

---@param cwd path_t
---@return boolean
function process.setCwd(cwd) end

---@return path_t
function process.getSelfExePath() end

---@param pid integer
---@param signal string
function process.kill(pid, signal) end

---@param code integer
function process.exit(code) end

---@return { rss: number, heap: number }
function process.memoryUsage() end

---@return { user: number, system: number }
function process.cpuUsage() end

return process
