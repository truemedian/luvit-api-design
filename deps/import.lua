local uv = require 'uv'

local bootstrap_import = ...

if bootstrap_import == 'import' then
    bootstrap_import = nil
end

---@type std.fs
local fs

if import then
    fs = import('fs').sync
else
    fs = { path = { posix = {} } }

    function fs.path.resolve(pathname, parent)
        if parent and parent ~= '' then
            return parent .. '/' .. pathname
        end

        return pathname
    end

    fs.path.posix.resolve = fs.path.resolve

    function fs.path.dirname(pathname)
        return string.match(pathname, '^(.+)/[^/]+/*$') or ''
    end

    function fs.path.basename(pathname, expected_ext)
        assert(expected_ext == nil)
        return string.match(pathname, '([^/]+)/*$')
    end

    function fs.path.extension(pathname)
        local basename = fs.path.basename(pathname)
        return string.match(basename, '[^%.](%.[^%.]*)$') or ""
    end

    fs.path.posix.extension = fs.path.extension

    function fs.path.relative(from, to)
        return from
    end

    fs.path.posix.relative = fs.path.relative

    function fs.path.join(...)
        return table.concat({...}, '/')
    end

    fs.path.posix.join = fs.path.join

    function fs.stat(path)
        return uv.fs_stat(path)
    end

    function fs.readFile(path)
        local fd = io.open(path, 'r')
        if fd == nil then
            return nil, 'file not found: ' .. path
        end

        local data = fd:read('*a')
        fd:close()

        return data
    end
end

local path = fs.path

local has_luvi, luvi = pcall(require, 'luvi')

local import = bootstrap_import or {}
import.stat_cache = {}
import.module_cache = {}
import.loaders = {}

function import.loaders.lua(name, file, content, env, ...)
    local fn, syntax_err = load(content, '@' .. file, "t", env)
    if not fn then
        error(string.format("error loading module %q from file %q:\n\t%s", name, file, syntax_err), 3)
    end

    return fn(...)
end

local function statFile(key, full_path, bundled, attempts)
    if import.stat_cache[key] ~= nil then
        return true
    end

    if bundled then
        local stat = luvi.bundle.stat(full_path)
        if not stat then
            attempts[#attempts + 1] = string.format("no file %q", key)

            return false
        end

        import.stat_cache[key] = stat
    else
        local stat = fs.stat(full_path)
        if not stat then
            attempts[#attempts + 1] = string.format("no file %q", key)

            return false
        end

        import.stat_cache[key] = stat
    end

    return true
end

---Note: A `nil` error with a missing key and path indicates file not found
---@return nil|string err
---@return string|nil cache_key
---@return string|nil full_path
---@return boolean|nil has_root
local function resolvePackage(module, name, attempts)
    local normalized_name = path.resolve(name, '')

    if not module.bundled then
        if path.extension(name) ~= '' then
            return nil, nil, nil
        end

        local full_path = path.join(module.project, 'deps', normalized_name)

        local key = 'fs:' .. full_path

        local key_single = key .. '.lua'
        local full_path_single = full_path .. '.lua'

        if statFile(key_single, full_path_single, false, attempts) then
            return nil, key_single, full_path_single, false
        end

        local key_multi = path.join(key, 'init.lua')
        local full_path_multi = path.join(full_path, 'init.lua')

        if statFile(key_multi, full_path_multi, false, attempts) then
            return nil, key_multi, full_path_multi, true
        end

        if import.global_package_cache == nil then
            import.global_package_cache = os.getenv("LUVI_CACHE_DIR") or false
        end

        if import.global_package_cache then
            local global_full_path = path.join(import.global_package_cache, normalized_name)

            local global_key = 'fs:' .. global_full_path

            local global_key_single = global_key .. '.lua'
            local global_full_path_single = global_full_path .. '.lua'

            if statFile(global_key_single, global_full_path_single, false, attempts) then
                return nil, global_key_single, global_full_path_single, false
            end

            local global_key_multi = path.join(global_key, 'init.lua')
            local global_full_path_multi = path.join(global_full_path, 'init.lua')

            if statFile(global_key_multi, global_full_path_multi, false, attempts) then
                return nil, global_key_multi, global_full_path_multi, true
            end
        end
    end

    if not has_luvi then
        return nil, nil, nil, nil
    end

    if path.posix.extension(name) ~= '' then
        return nil, nil, nil
    end

    -- always attempt to load packages from the bundle, but don't allow imports to escape the bundle once they enter.

    -- bundled deps should always be at the top
    local full_path = '/' .. path.posix.join('deps', normalized_name)

    local key = 'bundle:' .. full_path

    local key_single = key .. '.lua'
    local full_path_single = full_path .. '.lua'

    if statFile(key_single, full_path_single, true, attempts) then
        return nil, key_single, full_path_single, false
    end

    local key_multi = path.join(key, 'init.lua')
    local full_path_multi = path.join(full_path, 'init.lua')

    if statFile(key_multi, full_path_multi, true, attempts) then
        return nil, key_multi, full_path_multi, true
    end

    return nil, nil, nil
end

---Note: A `nil` error with a missing key and path indicates file not found
---@return nil|string err
---@return string|nil cache_key
---@return string|nil full_path
local function resolveRelative(module, name, attempts)
    if module.root == nil then
        return 'single file packages cannot import relative modules', nil, nil
    end

    if module.bundled then
        assert(has_luvi)

        if path.posix.extension(name) == '' then
            return nil, nil, nil
        end

        local full_path = path.posix.resolve(name, module.dir)

        local relative_to_root = path.posix.relative(module.root, full_path)

        if relative_to_root:sub(1, 2) == '..' then
            return 'import of file outside outside of package path', nil, nil
        end

        local key = 'bundle:' .. full_path

        if statFile(key, full_path, true, attempts) then
            return nil, key, full_path
        end

        return nil, nil, nil
    end

    if path.extension(name) == '' then
        return nil, nil, nil
    end

    local full_path = path.resolve(name, module.dir)

    local relative_to_root = path.relative(module.root, full_path)

    if relative_to_root:sub(1, 2) == '..' then
        return 'import of file outside outside of package path', nil, nil
    end

    local key = 'fs:' .. full_path

    if statFile(key, full_path, false, attempts) then
        return nil, key, full_path
    end

    return nil, nil, nil
end

local Module = {}
local Module_meta = { __index = Module }
local env_meta = { __index = _G }

---@return string|nil cache_key
---@return string|nil full_path
---@return nil|string err
---@return boolean is_package
---@return boolean|nil package_has_root
---@return table attempts
function Module:resolve(name)
    local key, full_path, err, package_has_root

    local is_package = true

    local attempts = {}

    err, key, full_path, package_has_root = resolvePackage(self, name, attempts)

    if not key then
        is_package = false

        err, key, full_path = resolveRelative(self, name, attempts)
    end

    return key, full_path, err, is_package, package_has_root, attempts
end

function Module:import(name, ...)
    local key, full_path, err, is_package, package_has_root, attempts = self:resolve(name)

    if not key then
        local attempt_str = table.concat(attempts, '\n\t')

        if err then -- something else went wrong
            error(string.format('module %q not found: %s\n\t%s', name, err, attempt_str))
        else -- the file was not found
            error(string.format('module %q not found:\n\t%s', name, attempt_str))
        end
    end

    if import.module_cache[key] ~= nil then
        return import.module_cache[key].exports
    end

    local full_path_extension = path.extension(full_path)
    local loader = import.loaders[full_path_extension:sub(2)]

    if not loader then
        error(string.format("error loading module %q from file %q: no import loader for %q files", name, key,
            full_path_extension), 2)
    end

    local is_bundled = key:sub(1, 7) == 'bundle:'

    local new_dir = path.dirname(full_path)
    local new_root, new_project

    if is_bundled then
        new_project = nil
    else
        new_project = self.project
    end

    if is_package then
        if package_has_root then
            new_root = new_dir
        end
    else
        new_root = self.root
    end

    local new_module = setmetatable({
        bundled = is_bundled,
        file = full_path,
        dir = new_dir,
        root = new_root,
        project = new_project,
        exports = {},
    }, Module_meta)

    local content
    if is_bundled then
        content = assert(luvi.bundle.readfile(full_path))
    else
        content = assert(fs.readFile(full_path))
    end

    local env = setmetatable({
        module = new_module,
        exports = new_module.exports,
        import = function(...)
            return new_module:import(...)
        end
    }, env_meta)

    local ret = loader(name, key, content, env, ...)

    import.module_cache[key] = new_module

    if ret ~= nil then
        new_module.exports = ret
    end

    return new_module.exports
end

function import.new(entrypoint, is_bundled)
    if is_bundled then
        assert(has_luvi)

        entrypoint = path.posix.resolve(entrypoint, '/')
    else
        entrypoint = path.resolve(entrypoint)
    end

    local dirname = path.dirname(entrypoint)

    local new_module = setmetatable({
        bundled = is_bundled,
        file = entrypoint,
        dir = dirname,
        root = dirname,
        project = dirname,
    }, Module_meta)

    return new_module
end

if not bootstrap_import then
    return import.new("fake.lua", has_luvi):import("import", import)
end

return import
