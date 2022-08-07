local uv = require 'uv'

---@class std.process
local process = {}

local env_meta = {}
function env_meta:__index(key)
    return os.getenv(key)
end

function env_meta:__newindex(key, value)
    if value then
        uv.os_setenv(key, value)
    else
        uv.os_unsetenv(key)
    end
end

process.env = setmetatable({}, env_meta)

process.pid = uv.os_getpid()
process.ppid = uv.os_getppid()

---@return path_t
function process.getCwd()
    return uv.cwd()
end

---@param new_cwd path_t
---@return boolean, string?, string?
function process.setCwd(new_cwd)
    local ret, err, errno = uv.chdir(new_cwd)
    return ret == 0, err, errno
end

---@return path_t
function process.getSelfExePath()
    return uv.exepath()
end

---@param pid integer
---@param signal string
function process.kill(pid, signal)
    return uv.kill(pid, signal)
end

---@param code integer
function process.exit(code)
    -- TODO: clean up stdio

    os.exit(code)
end

---@return { total: number, free: number, contstrained: number, rss: number, heap: number }
function process.memoryUsage()
    return {
        total = uv.get_total_memory(),
        free = uv.get_free_memory(),
        constrained = uv.get_constrained_memory(),
        rss = uv.resident_set_memory(),
        heap = collectgarbage('count') * 1024,
    }
end

---@return { user: number, system: number }
function process.cpuUsage()
    local usage = uv.getrusage()

    return {
        user_time = usage.utime.sec + usage.utime.usec / 1e6,
        system_time = usage.stime.sec + usage.stime.usec / 1e6,
        max_resident_memory = usage.maxrss,
        minor_page_fault = usage.minflt,
        major_page_fault = usage.majflt,
        file_input = usage.inblock,
        file_output = usage.oublock,
        voluntary_context_switch = usage.nvcsw,
        involuntary_context_switch = usage.nivcsw
    }
end

return process
