---@class std.fs.path
local path = {}

---@class std.fs.path.posix
path.posix = {}

---@class std.fs.path.windows
path.windows = {}

---@param pathname path_t
---@return boolean
function path.posix.isAbsolute(pathname) end

---@param pathname path_t
---@return boolean
function path.posix.isUNC(pathname) end

---@param pathname path_t
---@return boolean
function path.posix.isDriveRelative(pathname) end

---@param pathname path_t
---@return path_t
function path.posix.normalize(pathname) end

---@param pathname path_t
---@return path_t
function path.posix.getRoot(pathname) end

---@param paths path_t[]
---@return path_t
function path.posix.join(paths) end

---@param pathname path_t
---@return path_t[]
function path.posix.split(pathname) end

---@param pathname path_t
---@return path_t
function path.posix.resolve(pathname) end

---@param pathname path_t
---@return path_t
function path.posix.dirname(pathname) end

---@param pathname path_t
---@return string
function path.posix.basename(pathname) end

---@param pathname path_t
---@return string
function path.posix.extension(pathname) end

---@param from path_t
---@param to path_t
---@return path_t
function path.posix.relative(from, to) end

---@param pathname path_t
---@return boolean
function path.windows.isAbsolute(pathname) end

---@param pathname path_t
---@return boolean
function path.windows.isUNC(pathname) end

---@param pathname path_t
---@return boolean
function path.windows.isDriveRelative(pathname) end

---@param pathname path_t
---@return path_t
function path.windows.normalize(pathname) end

---@param pathname path_t
---@return path_t
function path.windows.getRoot(pathname) end

---@param paths path_t[]
---@return path_t
function path.windows.join(paths) end

---@param pathname path_t
---@return path_t[]
function path.windows.split(pathname) end

---@param pathname path_t
---@return path_t
function path.windows.resolve(pathname) end

---@param pathname path_t
---@return path_t
function path.windows.dirname(pathname) end

---@param pathname path_t
---@return string
function path.windows.basename(pathname) end

---@param pathname path_t
---@return string
function path.windows.extension(pathname) end

---@param from path_t
---@param to path_t
---@return path_t
function path.windows.relative(from, to) end

-- These are provided for easy access to the current platform's path functions.

path.isAbsolute = path.posix.isAbsolute
path.isUNC = path.posix.isUNC
path.isDriveRelative = path.posix.isDriveRelative
path.normalize = path.posix.normalize
path.getRoot = path.posix.getRoot
path.join = path.posix.join
path.split = path.posix.split
path.resolve = path.posix.resolve
path.dirname = path.posix.dirname
path.basename = path.posix.basename
path.extension = path.posix.extension
path.relative = path.posix.relative

return path
