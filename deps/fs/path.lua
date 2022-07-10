local uv = require 'uv'

---@class std.fs.path
local path = {}

---@class std.fs.path.posix
path.posix = {}

path.posix.sep = '/'

---@class std.fs.path.windows
path.windows = {}

path.windows.sep = '\\'

---Whether a path is absolute.
---@param pathname path_t
---@return boolean
function path.posix.isAbsolute(pathname)
    return string.sub(pathname, 1, 1) == '/'
end

---Returns a new path with no empty or redundant components
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

---Returns the root of the path, will be "." for relative paths.
---@param pathname path_t
---@return path_t
function path.posix.getRoot(pathname)
    if path.posix.isAbsolute(pathname) then
        return '/'
    else
        return "."
    end
end

---Joins a list of paths together, does not duplicate path separators. Starts at the last absolute path if any are provided.
---@param ... path_t[]
---@return path_t
function path.posix.join(...)
    local len = select('#', ...)

    if len == 0 then
        return ""
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

---Splits a path into its directory components.
---
---Empty segments are ignored and stripped out from the result.
---Beware: This includes the first component that is present on absolute paths.
---@param pathname path_t
---@return path_t[]
function path.posix.split(pathname)
    if pathname == '/' then
        return {}
    end

    local parts = {}

    local pos = 1
    local n = 1
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

---Strip the last component from a path.
---
---If the path is a file in the current directory (no directory component) or the root directory (just `/`)
---Then this returns the empty string
---@param pathname path_t
---@return path_t
function path.posix.dirname(pathname)
    return string.match(pathname, '^(.+)/[^/]+/*$') or ''
end

---Returns the name of a file from a path.
---
---If the path has trailing slashes, they are stripped off and ignored.
---
---If `expected_ext` is true, this will always strip the extension from the name.
---If `expected_ext` is a string, this will only strip that string from the end.
---@param pathname path_t
---@param expected_ext? string|true
---@return string
function path.posix.basename(pathname, expected_ext)
    local basename = string.match(pathname, '([^/]+)/*$')

    if expected_ext == true then
        local last_dot = string.find(basename, '%.[^%.]*$')

        if last_dot and last_dot ~= 1 then
            return string.sub(basename, 1, last_dot - 1)
        else
            return basename
        end
    elseif expected_ext then
        if string.find(basename, expected_ext, #basename - #expected_ext + 1, true) then
            return string.sub(basename, 1, - #expected_ext - 1)
        else
            return basename
        end
    else
        return basename
    end
end

---Returns the extension of the file name (if any).
---
---Files that end with a `.` are considered to have no extension.
---Files that start with a `.` do not consider the first `.` as an extension.
---
---Examples:
---    'init.lua' => '.lua'
---    'src/init.lua' => '.lua'
---    '.gitignore' => ''
---    'keep.' => '.'
---    'init.lua.keep' => '.keep'
---    'src/init.lua.keep/' => '.keep'
---@param pathname path_t
---@return string
function path.posix.extension(pathname)
    local basename = path.posix.basename(pathname)
    return string.match(basename, '[%.](%.[^%.]*)$') or ""
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

    return "."
end

---@param pathname path_t
---@return boolean
function path.windows.isAbsolute(pathname) end

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
