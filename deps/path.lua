local uv = require 'uv'

---@alias path_t string
---@class std.path
local path = {}

---@class std.path.posix
path.posix = {}
path.posix.sep = '/'

---@class std.path.windows
path.windows = {}
path.windows.sep = '\\'

---Whether a character is a valid path separator.
---@param char string
---@return boolean
function path.posix.isSeparator(char)
    return char == '/'
end

---Whether a path is absolute.
---@param pathname path_t
---@return boolean
function path.posix.isAbsolute(pathname)
    return string.sub(pathname, 1, 1) == '/'
end

---Strip the last component from a file path.
---
---If the path is a file in the current directory (no directory component) or
---the root directory, then this returns an empty string.
---@param pathname path_t 
---@return path_t
function path.posix.dirname(pathname)
    return string.match(pathname, '^(/?.-)/?[^/]+/*$') or ''
end

---Returns the name of a file from a path. Any trailing separators are ignored.
---@param pathname path_t
---@return string 
function path.posix.basename(pathname)
    return string.match(pathname, '([^/]+)/*$') or ''
end

---Returns the last extension of the file name (if any). Only the last `.` is
---considered when determining the file extension.
---
---Files that start with a `.` do not consider the first `.` as an extension.
---
---Examples:
--- - `'init.lua'` ⇒ `'.lua'`
--- - `'src/init.lua'` ⇒ `'.lua'`
--- - `'.gitignore'` ⇒ `''`
--- - `'.image.png'` ⇒ `'.png'`
--- - `'src/init.lua.keep/'` ⇒ `'.keep'`
---@param pathname path_t
---@return string
function path.posix.extension(pathname)
    local basename = path.posix.basename(pathname)
    return string.match(basename, '[^%.](%.[^%.]*)$') or ''
end

---Returns the root component of a given file path. This is either
---`'/'` (the root directory) or `'.'` (the current directory).
---@param pathname path_t
---@return path_t
function path.posix.getRoot(pathname)
    if path.posix.isAbsolute(pathname) then
        return '/'
    else
        return '.'
    end
end

---Returns a new path with no empty (`''`) or redundant (`'.'`) components
---@param pathname path_t
---@return path_t
function path.posix.normalize(pathname)
    local parts = path.posix.split(pathname)

    for i = #parts, 1, -1 do
        if parts[i] == '.' then
            table.remove(parts, i)
        end
    end

    local coalesced = table.concat(parts, '/')
    if path.posix.isAbsolute(pathname) then
        return '/' .. coalesced
    else
        return coalesced
    end
end

---Naively combines a series of paths together with the native path separator.
---
---The resulting path will begin with the last provided absolute component if
---any are provided.
---@param ... path_t
---@return path_t
function path.posix.join(...)
    local len = select('#', ...)

    if len == 0 then
        return ''
    end

    local i = len + 1
    local absolute = false
    while i > 1 do
        i = i - 1

        if path.posix.isAbsolute(select(i, ...)) then
            absolute = true
            break
        end
    end

    local parts, n = {}, 1

    if absolute then
        parts[1] = ''
        n = 2
    end

    while i <= len do
        local sub = path.posix.split(select(i, ...))
        for j = 1, #sub do
            parts[n] = sub[j]
            n = n + 1
        end

        i = i + 1
    end

    return table.concat(parts, '/')
end

---Splits a path into its directory components. The root of the path (`/` or
---`.`) is processed separately and stored in the `root` field.
---
---Duplicate path separators are treated as a single separator. No other
---normalization is performed.
---@param pathname path_t
---@return { [number]: path_t, root: string|nil }
function path.posix.split(pathname)
    if pathname == '/' then
        return {}
    end

    local parts = {}

    local pos = 1
    local n = 1

    if pathname:sub(1,1) == '/' then
        parts.root = '/'
        pos = 2
    elseif pathname:sub(1,2) == './' then
        parts.root = '.'
        pos = 3
    end

    while true do
        local next_sep = string.find(pathname, '/', pos, true)

        if next_sep then
            if next_sep ~= pos then -- skip empty segments
                parts[n] = string.sub(pathname, pos, next_sep - 1)
                n = n + 1
            end

            pos = next_sep + 1
        else
            parts[n] = string.sub(pathname, pos)
            break
        end
    end

    if parts[n] == '' then
        parts[n] = nil
    end

    return parts
end

---This function takes a path and returns a absolute path.
---
---If the path uses `..` segments on the root directory, they are discarded.
---It also resolves `.` and `..` segments.
---The result does not have a trailing separator
---
---If the path is relative, it uses `parent` or the current working directory as a starting point
---Note: This function may not be correct when used on symlinked paths, it will not follow symlinks.
---@param pathname path_t
---@param parent? path_t
---@return path_t
function path.posix.resolve(pathname, parent)
    local parts = path.posix.split(pathname)

    local is_absolute = true

    if not path.posix.isAbsolute(pathname) then
        local cwd_path = parent or uv.cwd()

        is_absolute = path.posix.isAbsolute(cwd_path)

        local cwd = path.posix.split(cwd_path)

        local len = #cwd
        for i = 1, #parts do
            cwd[len + i] = parts[i]
        end

        parts = cwd
    end

    local skip = 0
    for i = #parts, 1, -1 do
        if parts[i] == '.' then
            table.remove(parts, i)
        elseif parts[i] == '..' then
            table.remove(parts, i)
            skip = skip + 1
        elseif skip > 0 then
            table.remove(parts, i)
            skip = skip - 1
        end
    end

    local coalesced = table.concat(parts, '/')

    if is_absolute then
        return '/' .. coalesced

    else
        return coalesced
    end
end

---Returns the relative path from `from` to `to`.
---
---If `from` and `to` each resolve to the same path (after calling `resolve` on each), `"."` is returned.
---@param from path_t
---@param to path_t
---@return path_t
function path.posix.relative(from, to)
    from = path.posix.resolve(from)
    to = path.posix.resolve(to)

    local from_parts = path.posix.split(from)
    local to_parts = path.posix.split(to)

    local i = 1
    while true do
        local from_component = from_parts[i]
        local to_component = to_parts[i]

        if from_component == nil then
            return table.concat(to_parts, '/', i)
        end

        if from_component ~= to_component then
            local parts = {}

            for j = 1, #from_parts - i + 1 do
                parts[j] = '..'
            end

            local len = #parts
            for j = 1, #to_parts - i + 1 do
                parts[len + j] = to_parts[i + j - 1]
            end

            return table.concat(parts, '/')
        end

        i = i + 1
    end

    return '.'
end

-------------------------------------------------------------------------------

---Whether a character is a valid path separator.
---@param char string
---@return boolean
function path.windows.isSeparator(char)
    return char == '/' or char == '\\'
end

---Whether a path is absolute.
---@param pathname path_t
---@return boolean
function path.windows.isAbsolute(pathname)
    if #pathname == 0 then
        return false
    end

    -- /name
    if path.windows.isSeparator(string.sub(pathname, 1, 1)) then
        return true
    end

    if #pathname < 3 then
        return false
    end

    -- C:/name
    if string.sub(pathname, 2, 2) == ':' and path.windows.isSeparator(string.sub(pathname, 3, 3)) then
        return true
    end

    return false
end


---@param pathname path_t
---@return path_t
function path.windows.dirname(pathname)
    error('not yet implemented')
end

---@param pathname path_t
---@return string
function path.windows.basename(pathname)
    error('not yet implemented')
end

---@param pathname path_t
---@return string
function path.windows.extension(pathname)
    error('not yet implemented')
end

---@param pathname path_t
---@return path_t
function path.windows.getRoot(pathname)
    error('not yet implemented')
end

---@param pathname path_t
---@return path_t
function path.windows.normalize(pathname)
    error('not yet implemented')
end

---@param ... path_t
---@return path_t
function path.windows.join(...)
    error('not yet implemented')
end

---@param pathname path_t
---@return path_t[]
function path.windows.split(pathname)
    error('not yet implemented')
end

---@param pathname path_t
---@return path_t
function path.windows.resolve(pathname)
    error('not yet implemented')
end

---@param from path_t
---@param to path_t
---@return path_t
function path.windows.relative(from, to)
    error('not yet implemented')
end

-- These are provided for easy access to the current platform's path functions.

path.isSeparator = path.posix.isSeparator
path.isAbsolute = path.posix.isAbsolute
path.dirname = path.posix.dirname
path.basename = path.posix.basename
path.extension = path.posix.extension
path.getRoot = path.posix.getRoot
path.normalize = path.posix.normalize
path.join = path.posix.join
path.split = path.posix.split
path.resolve = path.posix.resolve
path.relative = path.posix.relative

return path
