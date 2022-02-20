---@class fslib
local fs = {}

fs.path = require('std.fs.path')

---@alias fd integer

---@alias open_flags integer|"r"|"rs"|"sr"|"r+"|"rs+"|"sr+"|"w"|"wx"|"xw"|"w+"|"wx+"|"xw+"|"a"|"ax"|"xa"|"a+"|"ax+"|"xa+"

---@alias struct_stat { dev: integer, mode: integer, nlink: integer, uid: integer, gid: integer, rdev: integer, ino: integer, size: integer, blksize: integer, blocks: integer, flags: integer, gen: integer, atime: { sec: integer, nsec: integer }, mtime: { sec: integer, nsec: integer }, ctime: { sec: integer, nsec: integer }, birthtime: { sec: integer, nsec: integer }, type: string }

---@alias struct_statfs { type: integer, bsize: integer, blocks: integer, bfree: integer, bavail: integer, files: integer, ffree: integer }

--- Functions that operate on paths

---@param path path
---@param flags "R"|"W"|"X"|integer
---@return boolean
function fs.access(path, flags) end

---@param path path
---@param mode integer
---@return boolean
function fs.chmod(path, mode) end

---@param path path
---@param uid integer
---@param gid integer
---@return boolean
function fs.chown(path, uid, gid) end

---@param path path
---@param new_path path
---@param mode? { excl: boolean, ficlone: boolean, ficlone_force: boolean }|integer
function fs.copyfile(path, new_path, mode) end

-- note: implement with `not not stat`?
---@param path path
---@return boolean
function fs.exists(path) end

---@param path path
---@param newPath path
---@return boolean
function fs.link(path, newPath) end

---@param path path
---@return struct_stat
function fs.lstat(path) end

---@param path path
---@param mode integer
---@return boolean
function fs.mkdir(path, mode) end

---@param template string
---@return path
function fs.mkdtemp(template) end

-- note: similar to scandir, but iterate internally
---@param path path
---@return path[]
function fs.readdir(path) end

---@param path path
---@return path
function fs.readlink(path) end

---@param path path
---@return path
function fs.realpath(path) end

---@param path path
---@param new_path path
---@return boolean
function fs.rename(path, new_path) end

---@param path path
---@return boolean
function fs.rmdir(path) end

-- note: abstract over fs_scandir + fs_scandir_next
---@param path path
---@return function
function fs.scandir(path) end

---@param path path
---@return struct_stat
function fs.stat(path) end

---@param path path
---@param new_path path
---@param flags? { dir: boolean, junction: boolean }|integer
function fs.symlink(path, new_path, flags) end

---@param path path
---@return boolean
function fs.unlink(path) end

---@param path path
---@param atime number
---@param mtime number
---@return boolean
function fs.utime(path, atime, mtime) end

--- Functions that operate on file descriptors

---@param path path
---@param flags open_flags
---@param mode integer
---@return fd
function fs.open(path, flags, mode) end

---@param fd fd
---@return boolean
function fs.close(fd) end

---@param fd fd
---@param mode integer
---@return boolean
function fs.fchmod(fd, mode) end

---@param fd fd
---@param uid integer
---@param gid integer
---@return boolean
function fs.fchown(fd, uid, gid) end

---@param fd fd
---@return boolean
function fs.fdatasync(fd) end

---@param fd fd
---@return struct_stat
function fs.fstat(fd) end

---@param fd fd
---@return boolean
function fs.fsync(fd) end

---@param fd fd
---@param offset integer
---@return boolean
function fs.ftruncate(fd, offset) end

---@param fd fd
---@param atime number
---@param mtime number
---@return boolean
function fs.futime(fd, atime, mtime) end

---@param fd fd
---@param size integer
---@param offset? integer
---@return string
function fs.read(fd, size, offset) end

---@param out_fd fd
---@param in_fd fd
---@param in_offset integer
---@param length integer
---@return integer
function fs.sendfile(out_fd, in_fd, in_offset, length) end

---@param fd fd
---@param data string
---@param offset? integer
---@return integer
function fs.write(fd, data, offset) end

--- Functions to provide easier API

---@param path path
---@param offset? integer
---@return string
function fs.readFile(path, offset) end

---@param path path
---@param data string
---@param offset? integer
---@return integer
function fs.writeFile(path, data, offset) end

return fs
