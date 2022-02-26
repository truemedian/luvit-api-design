---@class std.fs
local fs = {}

fs.path = require('std.fs.path')

---@alias fd_t integer
---@alias path_t string

---@alias std.fs.access_flags "R"|"W"|"X"|integer
---@alias std.fs.open_flags "r"|"rs"|"sr"|"r+"|"rs+"|"sr+"|"w"|"wx"|"xw"|"w+"|"wx+"|"xw+"|"a"|"ax"|"xa"|"a+"|"ax+"|"xa+"|integer

---@alias std.fs.stat_info { dev: integer, mode: integer, nlink: integer, uid: integer, gid: integer, rdev: integer, ino: integer, size: integer, blksize: integer, blocks: integer, flags: integer, gen: integer, atime: { sec: integer, nsec: integer }, mtime: { sec: integer, nsec: integer }, ctime: { sec: integer, nsec: integer }, birthtime: { sec: integer, nsec: integer }, type: string }

---@alias std.fs.statfs_info { type: integer, bsize: integer, blocks: integer, bfree: integer, bavail: integer, files: integer, ffree: integer }

--- Functions that operate on paths

---@param path path_t
---@param flags std.fs.access_flags
---@return boolean
---@error nil, string, string
function fs.access(path, flags) end

---@param path path_t
---@param mode integer
---@return boolean
---@error nil, string, string
function fs.chmod(path, mode) end

---@param path path_t
---@param uid integer
---@param gid integer
---@return boolean
---@error nil, string, string
function fs.chown(path, uid, gid) end

---@param path path_t
---@param new_path path_t
---@param mode? { excl: boolean, ficlone: boolean, ficlone_force: boolean }
---@error nil, string, string
function fs.copyfile(path, new_path, mode) end

---@param path path_t
---@param newPath path_t
---@return boolean
---@error nil, string, string
function fs.link(path, newPath) end

---@param path path_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.lstat(path) end

---@param path path_t
---@param mode integer
---@return boolean
---@error nil, string, string
function fs.mkdir(path, mode) end

---@param template string
---@return path_t
---@error nil, string, string
function fs.mkdtemp(template) end

-- note: similar to scandir, but iterate internally
---@param path path_t
---@return path_t[]
---@error nil, string, string
function fs.readdir(path) end

---@param path path_t
---@return path_t
---@error nil, string, string
function fs.readlink(path) end

---@param path path_t
---@return path_t
---@error nil, string, string
function fs.realpath(path) end

---@param path path_t
---@param new_path path_t
---@return boolean
---@error nil, string, string
function fs.rename(path, new_path) end

---@param path path_t
---@return boolean
---@error nil, string, string
function fs.rmdir(path) end

-- note: abstract over fs_scandir + fs_scandir_next
---@param path path_t
---@return function
---@error nil, string, string
function fs.scandir(path) end

---@param path path_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.stat(path) end

---@param path path_t
---@param new_path path_t
---@param flags? { dir: boolean, junction: boolean }
---@error nil, string, string
function fs.symlink(path, new_path, flags) end

---@param path path_t
---@return boolean
---@error nil, string, string
function fs.unlink(path) end

---@param path path_t
---@param atime number
---@param mtime number
---@return boolean
---@error nil, string, string
function fs.utime(path, atime, mtime) end

--- Functions that operate on file descriptors

---@param path path_t
---@param flags std.fs.open_flags
---@param mode integer
---@return integer
---@error nil, string, string
function fs.open(path, flags, mode) end

---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.close(fd) end

---@param fd fd_t
---@param mode integer
---@return boolean
---@error nil, string, string
function fs.fchmod(fd, mode) end

---@param fd fd_t
---@param uid integer
---@param gid integer
---@return boolean
---@error nil, string, string
function fs.fchown(fd, uid, gid) end

---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.fdatasync(fd) end

---@param fd fd_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.fstat(fd) end

---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.fsync(fd) end

---@param fd fd_t
---@param offset integer
---@return boolean
---@error nil, string, string
function fs.ftruncate(fd, offset) end

---@param fd fd_t
---@param atime number
---@param mtime number
---@return boolean
---@error nil, string, string
function fs.futime(fd, atime, mtime) end

---@param fd fd_t
---@param size integer
---@param offset? integer
---@return string
---@error nil, string, string
function fs.read(fd, size, offset) end

---@param out_fd fd_t
---@param in_fd fd_t
---@param in_offset integer
---@param length integer
---@return integer
---@error nil, string, string
function fs.sendfile(out_fd, in_fd, in_offset, length) end

---@param fd fd_t
---@param data string
---@param offset? integer
---@return integer
---@error nil, string, string
function fs.write(fd, data, offset) end

--- Functions to provide easier API

---@param path path_t
---@return boolean
function fs.exists(path) end

---@param path path_t
---@param size? integer
---@param offset? integer
---@return string
---@error nil, string, string
function fs.readFile(path, size, offset) end

---@param path path_t
---@param data string
---@param offset? integer
---@return integer
---@error nil, string, string
function fs.writeFile(path, data, offset) end

return fs
