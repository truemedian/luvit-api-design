---@class pathlib
local path = {}

---@alias path string

---@class pathlib_posix
path.posix = {}

---@class pathlib_windows
path.windows = {}

---@param path path
---@return boolean
function path.posix.isAbsolute(path) end

---@param path path
---@return boolean
function path.posix.isUNC(path) end

---@param path path
---@return boolean
function path.posix.isDriveRelative(path) end

---@param path path
---@return path
function path.posix.normalize(path) end

---@param path path
---@return path
function path.posix.getRoot(path) end

---@param paths path[]
---@return path
function path.posix.join(paths) end

---@param path path
---@return path
function path.posix.resolve(path) end

---@param path path
---@return path
function path.posix.dirname(path) end

---@param path path
---@return string
function path.posix.basename(path) end

---@param path path
---@return string
function path.posix.extension(path) end

---@param from path
---@param to path
---@return path
function path.posix.relative(from, to) end

---@param path path
---@return boolean
function path.windows.isAbsolute(path) end

---@param path path
---@return boolean
function path.windows.isUNC(path) end

---@param path path
---@return boolean
function path.windows.isDriveRelative(path) end

---@param path path
---@return path
function path.windows.normalize(path) end

---@param path path
---@return path
function path.windows.getRoot(path) end

---@param paths path[]
---@return path
function path.windows.join(paths) end

---@param path path
---@return path
function path.windows.resolve(path) end

---@param path path
---@return path
function path.windows.dirname(path) end

---@param path path
---@return string
function path.windows.basename(path) end

---@param path path
---@return string
function path.windows.extension(path) end

---@param from path
---@param to path
---@return path
function path.windows.relative(from, to) end

-- These are provided for easy access to the current platform's path functions.

path.isAbsolute = path.posix.isAbsolute
path.isUNC = path.posix.isUNC
path.isDriveRelative = path.posix.isDriveRelative
path.normalize = path.posix.normalize
path.getRoot = path.posix.getRoot
path.join = path.posix.join
path.resolve = path.posix.resolve
path.dirname = path.posix.dirname
path.basename = path.posix.basename
path.extension = path.posix.extension
path.relative = path.posix.relative

return path
