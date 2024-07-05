local Emitter = import('Emitter')

---@alias uv_process_t userdata

---@class std.ChildProcess : std.Emitter
---@field handle uv_process_t
---@field exit_code integer|nil
---@field exit_signal integer|nil
local ChildProcess = import('class').create('std.ChildProcess', Emitter)

---@alias spawn_options { args: string[]|nil, stdio: { number: uv_stream_t|integer|nil }, env: { string: string }|nil, cwd: path_t|nil, uid: integer|nil, gid: integer|nil, verbatim: boolean|nil, detached: boolean|nil, hide: boolean|nil }

-- TODO: we don't want to accept luv's spawn options table as it requires far to much effort. But how the options are structured depends entirely on implementation.
---@param path path_t
---@param options spawn_options
---@return std.ChildProcess
---@error nil, string, string
function ChildProcess.spawn(path, options)
    error('not yet implemented')
end

---@param path path_t
---@param options spawn_options
---@return { code: integer, signal: integer|nil, stdout: string, stderr: string }
function ChildProcess.exec(path, options)
    error('not yet implemented')
end

---@param handle uv_process_t
---@return std.ChildProcess
function ChildProcess:init(handle)
    error('not yet implemented')
end

---@param signal string|integer
---@return boolean
---@error nil, string, string
function ChildProcess:kill(signal)
    error('not yet implemented')
end

---@return { code: integer, signal: integer|nil }
function ChildProcess:wait()
    error('not yet implemented')
end

return ChildProcess
