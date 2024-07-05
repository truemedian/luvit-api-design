local uv = require 'uv'

---@alias fd_t integer
---@alias uv_fs_t userdata

---@alias std.fs.stat_info { dev: integer, mode: integer, nlink: integer, uid: integer, gid: integer, rdev: integer, ino: integer, size: integer, blksize: integer, blocks: integer, flags: integer, gen: integer, atime: { sec: integer, nsec: integer }, mtime: { sec: integer, nsec: integer }, ctime: { sec: integer, nsec: integer }, birthtime: { sec: integer, nsec: integer }, type: string }

---@alias std.fs.statfs_info { type: integer, bsize: integer, blocks: integer, bfree: integer, bavail: integer, files: integer, ffree: integer }

---@class std.fs
local fs = {}

---The default permissions for a new directory.
fs.mode_directory = tonumber('644', 8)

---The default permissions for a new file.
fs.mode_file = tonumber('755', 8)

------------------------------------------------------------------------------------------------------------------------
---                                       Functions that operate on file paths                                       ---
------------------------------------------------------------------------------------------------------------------------

---Checks whether the current process has the requested permissions for the file at `path`.
---
---Equivalent to [`access(2)`](https://man7.org/linux/man-pages/man2/access.2.html) in Posix.
---@param path path_t
---@param flags "R" | "W" | "X"
---@return boolean | nil allowed
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.access(path, flags)
    return uv.fs_access(path, flags)
end

---Changes the permissions of the file at `path`.
---
---If `mode` is a string, it is interpreted as octal digits.
---
---Equivalent to [`chmod(2)`](https://man7.org/linux/man-pages/man2/chmod.2.html) in Posix.
---@param path path_t
---@param mode integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.chmod(path, mode)
    if type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_chmod(path, mode)
end

---Changes the ownership of the file at `path`.
---
---Equivalent to [`chown(2)`](https://man7.org/linux/man-pages/man2/chown.2.html) in Posix.
---@param path path_t
---@param uid integer
---@param gid integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.chown(path, uid, gid)
    return uv.fs_chown(path, uid, gid)
end

---Copies a file from `path` to `new_path`.
---
---If `mode` is provided, it is a table with the following fields:
---
---* `excl`: If true, the operation will fail if `new_path` already exists.
---* `ficlone`: If true, the operation will attempt to create a copy-on-write reflink. Will silently fall back to a normal copy.
---* `ficlone_force`: If true, the operation will attempt to create a copy-on-write reflink. Will fail if the operation is not supported.
---@param path path_t
---@param new_path path_t
---@param mode? { excl: boolean, ficlone: boolean, ficlone_force: boolean }
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.copyfile(path, new_path, mode)
    return uv.fs_copyfile(path, new_path, mode)
end

---Creates a hard link from `path` to `new_path`.
---
---Equivalent to [`link(2)`](https://man7.org/linux/man-pages/man2/link.2.html) in Posix.
---@param path path_t
---@param new_path path_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.link(path, new_path)
    return uv.fs_link(path, new_path)
end

---Returns information about the file at `path`. If `path` is a symbolic link, returns information about the link itself.
---
---Equivalent to [`lstat(2)`](https://man7.org/linux/man-pages/man2/lstat.2.html) in Posix.
---@param path path_t
---@return std.fs.stat_info | nil info
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.lstat(path)
    return uv.fs_lstat(path)
end

---Creates a new directory with the given permissions. The default permissions are described in `fs.mode_directory`.
---
---Equivalent to [`mkdir(2)`](https://man7.org/linux/man-pages/man2/mkdir.2.html) in Posix. 
---@param path path_t
---@param mode? integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.mkdir(path, mode)
    if mode == nil then
        mode = fs.mode_directory
    end

    return uv.fs_mkdir(path, mode)
end

---Creates a unique temporary directory with the given template. The last six characters of the template must be 'XXXXXX'.
---
---Equivalent to [`mkdtemp(3)`](https://man7.org/linux/man-pages/man3/mkdtemp.3.html) in Posix.
---@param template string
---@return path_t | nil temp_path
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.mkdtemp(template)
    return uv.fs_mkdtemp(template)
end

---Returns a table of file entries for the provided directory.
---@param path path_t
---@return ({name: path_t, type: string}[]) | nil entries
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.readdir(path)
    local res = {}

    for name, typ in fs.scandir(path) do
        table.insert(res, {name = name, type = typ})
    end

    return res
end

---Returns the target of a symbolic link.
---
---Equivalent to [`readlink(2)`](https://man7.org/linux/man-pages/man2/readlink.2.html) in Posix.
---@param path path_t
---@return path_t | nil target_path
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.readlink(path)
    return uv.fs_readlink(path)
end

---Returns the canonicalized absolute pathname of `path`. This function has many problems, especially on windows, and
---should be avoided for most use cases.
---
---Equivalent to [`realpath(3)`](https://man7.org/linux/man-pages/man3/realpath.3.html) in Posix.
---@param path path_t
---@return path_t | nil real_path
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.realpath(path)
    return uv.fs_realpath(path)
end

---Changes the name of a the given file, moving it between directories if necessary.
---
---Equivalent to [`rename(2)`](https://man7.org/linux/man-pages/man2/rename.2.html) in Posix.
---@param path path_t
---@param new_path path_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.rename(path, new_path)
    return uv.fs_rename(path, new_path)
end

---Deletes an empty directory.
---
---Equivalent to [`rmdir(2)`](https://man7.org/linux/man-pages/man2/rmdir.2.html) in Posix.
---@param path path_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.rmdir(path)
    return uv.fs_rmdir(path)
end

---Returns a function that can be used to iterate over the entries in a directory.
---
---Equivalent to [`scandir(3)`](https://man7.org/linux/man-pages/man3/scandir.3.html) in Posix.
---@param path path_t
---@return (fun(): string | nil, string) | nil iterator
---@return uv_fs_t | string | nil state
---@return string | nil errno
---@nodiscard
function fs.scandir(path)
    local req, err, errno = uv.fs_scandir(path)
    if not req then
        return nil, err, errno
    end

    return uv.fs_scandir_next, req
end

---Returns information about the file at `path`.
---
---Equivalent to [`stat(2)`](https://man7.org/linux/man-pages/man2/stat.2.html) in Posix.
---@param path path_t
---@return std.fs.stat_info | nil info
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.stat(path)
    return uv.fs_stat(path)
end

---Creates a symbolic link from `path` to `new_path`.
---
---On windows `flags` can be provided, it is a table with the following fields:
---
---* `dir`: If true, indicates that `path` points to a directory.
---* `junction`: If true, requests that the symlink is created using junction points.
---
---Equivalent to [`symlink(2)`](https://man7.org/linux/man-pages/man2/symlink.2.html) in Posix.
---@param path path_t
---@param new_path path_t
---@param flags? { dir: boolean, junction: boolean }
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.symlink(path, new_path, flags)
    return uv.fs_symlink(path, new_path, flags)
end

---Deletes a name from the filesystem. This also deletes the file if it is the last name referring to the file.
---
---Equivalent to [`unlink(2)`](https://man7.org/linux/man-pages/man2/unlink.2.html) in Posix.
---@param path path_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.unlink(path)
    return uv.fs_unlink(path)
end

---Changes the last access and modification times of the file at `path`.
---
---Equivalent to [`utime(2)`](https://man7.org/linux/man-pages/man2/utime.2.html) in Posix.
---@param path path_t
---@param atime number
---@param mtime number
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.utime(path, atime, mtime)
    return uv.fs_utime(path, atime, mtime)
end

------------------------------------------------------------------------------------------------------------------------
---                                    Functions that operate on file descriptors                                    ---
------------------------------------------------------------------------------------------------------------------------

---Opens and possibly creates a file at `path`. The default permissions for a new file are described in `fs.mode_file`.
---
---The characters in `flags` have the following meanings:
---
---* `r`: Open file for reading. The stream is positioned at the beginning of the file.
---* `r+`: Open file for reading and writing. The stream is positioned at the beginning of the file.
---* `rs`: Like `r` but write operations will operate synchronously, as if `fsync` was called after each write.
---* `rs+`: Like `r+` but write operations will operate synchronously, as if `fsync` was called after each write.
---* `w`: Open file for writing. The file is created if it does not exist or truncated. The stream is positioned at the beginning of the file.
---* `w+`: Open file for reading and writing. The file is created if it does not exist or truncated. The stream is positioned at the beginning of the file.
---* `wx`: Like `w` but fails if the path already exists.
---* `wx+`: Like `w+` but fails if the path already exists.
---* `a`: Open file for appending. The file is created if it does not exist. The stream is positioned at the end of the file.
---* `a+`: Open file for reading and appending. The file is created if it does not exist. The stream is positioned at the end of the file.
---* `ax`: Like `a` but fails if the path already exists.
---* `ax+`: Like `a+` but fails if the path already exists.
---
---If `mode` is a string, it is interpreted as octal digits.
---
---Equivalent to [`open(2)`](https://man7.org/linux/man-pages/man2/open.2.html) in Posix.
---@param path path_t
---@param flags "r"|"r+"|"rs"|"rs+"|"w"|"w+"|"wx"|"wx+"|"a"|"a+"|"ax"|"ax+"|integer
---@param mode? integer | string
---@return fd_t | nil file_descriptor
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.open(path, flags, mode)
    if mode == nil then
        mode = fs.mode_file
    elseif type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_open(path, flags, mode)
end

---Closes a file descriptor.
---
---Equivalent to [`close(2)`](https://man7.org/linux/man-pages/man2/close.2.html) in Posix.
---@param fd fd_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.close(fd)
    return uv.fs_close(fd)
end

---Changes the permissions of the file descriptor.
---
---If `mode` is a string, it is interpreted as octal digits.
---
---Equivalent to [`fchmod(2)`](https://man7.org/linux/man-pages/man2/fchmod.2.html) in Posix.
---@param fd fd_t
---@param mode integer | string
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.fchmod(fd, mode)
    if type(mode) == 'string' then
        mode = tonumber(mode, 8)
    end

    return uv.fs_fchmod(fd, mode)
end

---Changes the ownership of the file descriptor.
---
---Equivalent to [`fchown(2)`](https://man7.org/linux/man-pages/man2/fchown.2.html) in Posix.
---@param fd fd_t
---@param uid integer
---@param gid integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.fchown(fd, uid, gid)
    return uv.fs_fchown(fd, uid, gid)
end

---Flushes all modified data to disk, any only enough metadata to allow the operating system to access the file.
---
---Equivalent to [`fdatasync(2)`](https://man7.org/linux/man-pages/man2/fdatasync.2.html) in Posix.
---@param fd fd_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.fdatasync(fd)
    return uv.fs_fdatasync(fd)
end

---Returns information about the file descriptor.
---
---Equivalent to [`fstat(2)`](https://man7.org/linux/man-pages/man2/fstat.2.html) in Posix.
---@param fd fd_t
---@return std.fs.stat_info | nil info
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.fstat(fd)
    return uv.fs_fstat(fd)
end

---Flushes all modified data to disk, including metadata.
---
---Equivalent to [`fsync(2)`](https://man7.org/linux/man-pages/man2/fsync.2.html) in Posix.
---@param fd fd_t
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.fsync(fd)
    return uv.fs_fsync(fd)
end

---Truncates, or extends, a file to a specified length.
---
---Equivalent to [`ftruncate(2)`](https://man7.org/linux/man-pages/man2/ftruncate.2.html) in Posix.
---@param fd fd_t
---@param offset integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.ftruncate(fd, offset)
    return uv.fs_ftruncate(fd, offset)
end

---Updates the access and modification times of a file descriptor.
---
---Equivalent to [`futime(2)`](https://man7.org/linux/man-pages/man2/futime.2.html) in Posix.
---@param fd fd_t
---@param atime number
---@param mtime number
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.futime(fd, atime, mtime)
    return uv.fs_futime(fd, atime, mtime)
end

---Reads data from a file descriptor at the specified offset. It is not an error if the data is shorter than the requested size.
---
---Equivalent to [`pread(2)`](https://man7.org/linux/man-pages/man2/pread.2.html) in Posix.
---
---Size defaults to 4096.
---@param fd fd_t
---@param size? integer
---@param offset? integer
---@return string | nil data
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.read(fd, size, offset)
    if size == nil then
        size = 4096
    end

    return uv.fs_read(fd, size, offset)
end

---Transfers data from one file descriptor to another. It is not an error if not all data is transferred.
---
---Equivalent to [`sendfile(2)`](https://man7.org/linux/man-pages/man2/sendfile.2.html) in Posix.
---@param out_fd fd_t
---@param in_fd fd_t
---@param in_offset integer
---@param length integer
---@return integer | nil bytes_written
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.sendfile(out_fd, in_fd, in_offset, length)
    return uv.fs_sendfile(out_fd, in_fd, in_offset, length)
end

---Writes data to a file descriptor at the specified offset. It is not an error if not all data is written.
---
---Equivalent to [`pwrite(2)`](https://man7.org/linux/man-pages/man2/pwrite.2.html) in Posix.
---@param fd fd_t
---@param data string
---@param offset? integer
---@return integer | nil bytes_written
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.write(fd, data, offset)
    return uv.fs_write(fd, data, offset)
end

--- Functions to provide easier API

---Returns whether a file or directory exists at `path`. The user may not be able to access it.
---@param path path_t
---@return boolean exists
---@nodiscard
function fs.exists(path)
    return fs.stat(path) ~= nil
end

---Reads an entire file and returns its contents.
---@param path path_t
---@param size? integer
---@param offset? integer
---@return string | nil data
---@return string | nil error
---@return string | nil errno
---@nodiscard
function fs.readFile(path, size, offset)
    local fd, stat, chunk, err, errno

    fd, err, errno = fs.open(path, 'r')
    if fd == nil then
        return nil, err, errno
    end

    if size == nil then
        stat, err, errno = fs.fstat(fd)
        if stat == nil then
            fs.close(fd)

            return nil, err, errno
        end

        size = stat.size
    end

    if offset == nil then
        offset = 0
    end

    if size == 0 then
        size = 8192
    end

    local chunks, n, pos = {}, 1, offset
    while true do
        chunk, err, errno = fs.read(fd, size, pos)
        if chunk == nil then
            fs.close(fd)

            return nil, err, errno
        end

        if #chunk == 0 then
            break
        end

        pos = pos + #chunk
        chunks[n] = chunk
        n = n + 1
    end

    fs.close(fd)

    return table.concat(chunks)
end

---Writes all of `data` to `path`.
---
---If offset is provided, the file is not truncated and the data is written at the offset.
---@async
---@param path path_t
---@param data string
---@param offset? integer
---@return boolean | nil success
---@return string | nil error
---@return string | nil errno
function fs.writeFile(path, data, offset)
    local fd, err, errno, written

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
        return nil, err, errno
    end

    local total_written = 0
    while total_written < #data do
        written, err, errno = fs.write(fd, data:sub(total_written + 1), offset)
        if written == nil then
            fs.close(fd)

            return nil, err, errno
        end

        total_written = total_written + written
        offset = offset + written
    end

    fs.close(fd)

    return true
end

return fs
