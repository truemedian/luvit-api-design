local uv = require 'uv'

---@class std.fs
local fs = {}

---@type std.fs.path
fs.path = import('path.lua')

---@alias fd_t integer
---@alias path_t string

---@alias std.fs.stat_info { dev: integer, mode: integer, nlink: integer, uid: integer, gid: integer, rdev: integer, ino: integer, size: integer, blksize: integer, blocks: integer, flags: integer, gen: integer, atime: { sec: integer, nsec: integer }, mtime: { sec: integer, nsec: integer }, ctime: { sec: integer, nsec: integer }, birthtime: { sec: integer, nsec: integer }, type: string }

---@alias std.fs.statfs_info { type: integer, bsize: integer, blocks: integer, bfree: integer, bavail: integer, files: integer, ffree: integer }

local function assertResume(thread, ...)
    local success, err = coroutine.resume(thread, ...)
    if not success then
        error(debug.traceback(thread, err), 0)
    end
end

local function wait()
    local thread = coroutine.running()

    return function(err, value, ...)
        if err then
            local errno = string.match(err, '^([^:]+)')

            assertResume(thread, nil, err, errno)
        else
            if value == nil then
                assertResume(thread, true, ...)
            else
                assertResume(thread, value, ...)
            end
        end
    end
end

--- Functions that operate on paths

---Equivalent to `access(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param flags "R"|"W"|"X"
---@return boolean
---@error nil, string, string
function fs.access(path, flags)
    return uv.fs_access(path, flags)
end

---Equivalent to `chmod(2)` on Unix. See luv documentation for more information.
---
---If `mode` is a string, it is interpreted as octal digits.
---@param path path_t
---@param mode integer
---@return boolean
---@error nil, string, string
function fs.chmod(path, mode)
    if type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_chmod(path, mode)
end

---Equivalent to `chown(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param uid integer
---@param gid integer
---@return boolean
---@error nil, string, string
function fs.chown(path, uid, gid)
    return uv.fs_chown(path, uid, gid)
end

---Copies a file from `path` to `new_path`. See luv documentation for more information.
---@async
---@param path path_t
---@param new_path path_t
---@param mode? { excl: boolean, ficlone: boolean, ficlone_force: boolean }
---@return boolean
---@error nil, string, string
function fs.copyfile(path, new_path, mode)
    uv.fs_copyfile(path, new_path, mode, wait())

    return coroutine.yield()
end

---Equivalent to `link(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param new_path path_t
---@return boolean
---@error nil, string, string
function fs.link(path, new_path)
    return uv.fs_link(path, new_path)
end

---Equivalent to `lstat(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.lstat(path)
    return uv.fs_lstat(path)
end

---Equivalent to `mkdir(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param mode integer
---@return boolean
---@error nil, string, string
function fs.mkdir(path, mode)
    return uv.fs_mkdir(path, mode)
end

---Equivalent to `mkdtemp(3)` on Unix. See luv documentation for more information.
---@param template string
---@return path_t
---@error nil, string, string

function fs.mkdtemp(template)
    return uv.fs_mkdtemp(template)
end

---@param path path_t
---@return {name: path_t, type: string}[]
---@error nil, string, string
function fs.readdir(path)
    local res = {}

    for name, typ in fs.scandir(path) do
        table.insert(res, { name = name, type = typ })
    end

    return res
end

---Equivalent to `readlink(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@return path_t
---@error nil, string, string
function fs.readlink(path)
    return uv.fs_readlink(path)
end

---Equivalent to `realpath(3)` on Unix. See luv documentation for more information.
---@param path path_t
---@return path_t
---@error nil, string, string
function fs.realpath(path)
    return uv.fs_realpath(path)
end

---Equivalent to `rename(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param new_path path_t
---@return boolean
---@error nil, string, string
function fs.rename(path, new_path)
    return uv.fs_rename(path, new_path)
end

---Equivalent to `rmdir(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@return boolean
---@error nil, string, string
function fs.rmdir(path)
    return uv.fs_rmdir(path)
end

-- note: abstract over fs_scandir + fs_scandir_next
---@param path path_t
---@return fun(): string, string
---@error nil, string, string
function fs.scandir(path)
    local req, err, errno = uv.fs_scandir(path)
    if not req then
        ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
        return nil, err, errno
    end

    return function()
        local res, next_err, next_errno = uv.fs_scandir_next(req)
        if not res then
            return nil, next_err, next_errno
        end

        return res, next_err
    end
end

---Equivalent to `stat(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.stat(path)
    return uv.fs_stat(path)
end

---Equivalent to `symlink(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param new_path path_t
---@param flags? { dir: boolean, junction: boolean }
---@return boolean
---@error nil, string, string
function fs.symlink(path, new_path, flags)
    return uv.fs_symlink(path, new_path, flags)
end

---Equivalent to `unlink(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@return boolean
---@error nil, string, string
function fs.unlink(path)
    return uv.fs_unlink(path)
end

---Equivalent to `utime(2)` on Unix. See luv documentation for more information.
---@param path path_t
---@param atime number
---@param mtime number
---@return boolean
---@error nil, string, string
function fs.utime(path, atime, mtime)
    return uv.fs_utime(path, atime, mtime)
end

--- Functions that operate on file descriptors

---Equivalent to `open(2)` on Unix. See luv documentation for more information.
---
---If `mode` is a string, it is interpreted as octal digits.
---@param path path_t
---@param flags "r"|"r+"|"rs"|"rs+"|"w"|"w+"|"wx"|"wx+"|"a"|"a+"|"ax"|"ax+"|integer
---@param mode integer|string
---@return integer
---@error nil, string, string
---@nodiscard
function fs.open(path, flags, mode)
    if type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_open(path, flags, mode)
end

---Equivalent to `close(2)` on Unix. See luv documentation for more information.
---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.close(fd)
    return uv.fs_close(fd)
end

---Equivalent to `fchmod(2)` on Unix. See luv documentation for more information.
---
---If `mode` is a string, it is interpreted as octal digits.
---@param fd fd_t
---@param mode integer|string
---@return boolean
---@error nil, string, string
function fs.fchmod(fd, mode)
    if type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_fchmod(fd, mode)
end

---Equivalent to `fchown(2)` on Unix. See luv documentation for more information.
---@param fd fd_t
---@param uid integer
---@param gid integer
---@return boolean
---@error nil, string, string
function fs.fchown(fd, uid, gid)
    return uv.fs_fchown(fd, uid, gid)
end

---Equivalent to `fdatasync(2)` on Unix. See luv documentation for more information.
---@async
---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.fdatasync(fd)
    uv.fs_fdatasync(fd, wait())

    return coroutine.yield()
end

---Equivalent to `fstat(2)` on Unix. See luv documentation for more information.
---@param fd fd_t
---@return std.fs.stat_info
---@error nil, string, string
function fs.fstat(fd)
    return uv.fs_fstat(fd)
end

---Equivalent to `fsync(2)` on Unix. See luv documentation for more information.
---@async
---@param fd fd_t
---@return boolean
---@error nil, string, string
function fs.fsync(fd)
    uv.fs_fsync(fd, wait())

    return coroutine.yield()
end

---Equivalent to `ftruncate(2)` on Unix. See luv documentation for more information.
---@async
---@param fd fd_t
---@param offset integer
---@return boolean
---@error nil, string, string
function fs.ftruncate(fd, offset)
    uv.fs_ftruncate(fd, offset, wait())

    return coroutine.yield()
end

---Equivalent to `futime(2)` on Unix. See luv documentation for more information.
---@param fd fd_t
---@param atime number
---@param mtime number
---@return boolean
---@error nil, string, string
function fs.futime(fd, atime, mtime)
    return uv.fs_futime(fd, atime, mtime)
end

---Equivalent to `preadv(2)` on Unix. See luv documentation for more information.
---
---Size defaults to 4096.
---@async
---@param fd fd_t
---@param size? integer
---@param offset? integer
---@return string
---@error nil, string, string
function fs.read(fd, size, offset)
    if size == nil then
        size = 4096
    end

    uv.fs_read(fd, size, offset, wait())

    return coroutine.yield()
end

---Equivalent to `sendfile(2)` on Unix. See luv documentation for more information.
---
---Note: may do a partial write
---@async
---@param out_fd fd_t
---@param in_fd fd_t
---@param in_offset integer
---@param length integer
---@return integer
---@error nil, string, string
function fs.sendfile(out_fd, in_fd, in_offset, length)
    uv.fs_sendfile(out_fd, in_fd, in_offset, length, wait())

    return coroutine.yield()
end

---Equivalent to `pwritev(2)` on Unix. See luv documentation for more information.
---
---Note: may do a partial write
---@async
---@param fd fd_t
---@param data string
---@param offset? integer
---@return integer
---@error nil, string, string
function fs.write(fd, data, offset)
    uv.fs_write(fd, data, offset, wait())

    return coroutine.yield()
end

--- Functions to provide easier API

---Returns whether a file or directory exists at `path`. The user may not be able to access it.
---@param path path_t
---@return boolean
function fs.exists(path)
    local stat = fs.stat(path)

    return stat ~= nil
end

---Reads an entire file and returns its contents.
---@async
---@param path path_t
---@param size? integer
---@param offset? integer
---@return string
---@error nil, string, string
function fs.readFile(path, size, offset)
    local fd, stat, chunk, err, errno

    fd, err, errno = fs.open(path, 'r', '444')
    if fd == nil then
        ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
        return nil, err, errno
    end

    if size == nil then
        stat, err, errno = fs.fstat(fd)
        if stat == nil then
            ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
            return nil, err, errno
        end

        size = stat.size
    end

    if offset == nil then
        offset = 0
    end

    if size > 0 then
        chunk, err, errno = fs.read(fd, size, offset)

        if chunk == nil then
            ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
            return nil, err, errno
        end
    else
        local chunks, n, pos = {}, 1, offset
        while true do
            chunk, err, errno = fs.read(fd, 8192, pos)
            if chunk == nil then
                ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
                return nil, err, errno
            end

            if #chunk == 0 then
                break
            end

            pos = pos + #chunk
            chunks[n] = chunk
            n = n + 1
        end

        chunk = table.concat(chunks)
    end

    return chunk
end

---Writes `data` to `path`.
---
---If offset is provided, the file is not truncated and the data is written at the offset.
---@async
---@param path path_t
---@param data string
---@param offset? integer
---@return integer
---@error nil, string, string
function fs.writeFile(path, data, offset)
    local fd, written, err, errno

    local flag

    if offset == nil then
        offset = 0

        flag = 'w'
    else
        ---@type integer
        flag = uv.constants.O_WRONLY + uv.constants.O_CREAT
    end

    fd, err, errno = fs.open(path, flag, '644')
    if fd == nil then
        ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
        return nil, err, errno
    end

    written, err, errno = fs.write(fd, data, offset)
    if written == nil then
        ---@diagnostic disable-next-line: redundant-return-value, return-type-mismatch
        return nil, err, errno
    end

    fs.close(fd)

    return written
end

return fs
