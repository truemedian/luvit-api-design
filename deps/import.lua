---@type std.fs
local fs = import('fs/init.lua')
local path = fs.path

local has_luvi, luvi = pcall(require, 'luvi')

local import = {}
import.stat_cache = {}
import.module_cache = {}

local function statFile(key, full_path, bundled)
    if import.stat_cache[key] ~= nil then
        return true
    end

    if bundled then
        local stat = luvi.bundle.stat(full_path)
        if not stat then
            return false
        end

        import.stat_cache[key] = stat
    else
        local stat = fs.stat(full_path)
        if not stat then
            return false
        end

        import.stat_cache[key] = stat
    end

    return true
end

---@return nil|string err
---@return string|nil cache_key
---@return string|nil full_path
---@return boolean|nil has_root
local function resolvePackage(module, name)
    local normalized_name = path.resolve(name, '')

    if not module.bundled then
        local full_path = path.join(module.project, 'deps', normalized_name)

        local key = 'fs:' .. full_path

        local key_suffix = key .. '.lua'
        local full_path_suffix = full_path .. '.lua'

        if statFile(key_suffix, full_path_suffix, false) then
            return nil, key_suffix, full_path_suffix, false
        else
            local key_init = path.join(key, 'init.lua')
            local full_path_init = path.join(full_path, 'init.lua')

            if statFile(key_init, full_path_init, false) then
                return nil, key_init, full_path_init, true
            else
                return 'file not found', nil, nil, nil
            end
        end
    end

    if not has_luvi then
        return 'file not found', nil, nil, nil
    end

    -- always attempt to load packages from the bundle, but don't allow imports to escape the bundle once they enter.

    -- bundled deps should always be at the top
    local full_path = '/' .. path.posix.join('deps', normalized_name)

    local key = 'bundle:' .. full_path

    local key_suffix = key .. '.lua'
    local full_path_suffix = full_path .. '.lua'

    if statFile(key_suffix, full_path_suffix, true) then
        return nil, key_suffix, full_path_suffix, false
    else
        local key_init = path.join(key, 'init.lua')
        local full_path_init = path.join(full_path, 'init.lua')

        if statFile(key_init, full_path_init, true) then
            return nil, key_init, full_path_init, true
        else
            return 'file not found', nil, nil
        end
    end
end

---@return nil|string err
---@return string|nil cache_key
---@return string|nil full_path
local function resolveRelative(module, name)
    if module.root == nil then
        return 'single file modules cannot import relative modules', nil, nil
    end

    if module.bundled then
        assert(has_luvi)

        local full_path = path.posix.resolve(name, module.dir)

        local relative_to_root = path.posix.relative(module.root, full_path)

        if relative_to_root:sub(1, 2) == '..' then
            return 'import of file outside outside of package path', nil, nil
        end

        local key = 'bundle:' .. full_path

        if statFile(key, full_path, true) then
            return nil, key, full_path
        else
            return 'file not found', nil, nil
        end
    else
        local full_path = path.resolve(name, module.dir)

        local relative_to_root = path.relative(module.root, full_path)

        if relative_to_root:sub(1, 2) == '..' then
            return 'import of file outside outside of package path', nil, nil
        end

        local key = 'fs:' .. full_path

        if statFile(key, full_path, false) then
            return nil, key, full_path
        else
            return 'file not found', nil, nil
        end
    end
end

local Module = {}
local Module_meta = { __index = Module }
local env_meta = { __index = _G }

---@return string|nil cache_key
---@return string|nil full_path
---@return nil|string err
---@return boolean is_package
---@return boolean|nil package_has_root
function Module:resolve(name)
    local key, full_path, err, package_has_root

    local is_package = true

    err, key, full_path, package_has_root = resolvePackage(self, name)

    if not key then
        is_package = false

        err, key, full_path = resolveRelative(self, name)
    end

    return key, full_path, err, is_package, package_has_root
end

function Module:import(name, ...)
    local key, full_path, err, is_package, package_has_root = self:resolve(name)

    if not key then
        error(string.format('module %q not found: %s', name, err))
    end

    if import.module_cache[key] ~= nil then
        return import.module_cache[key].exports
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

    local fn, syntax_err = load(content, key, "t", env)
    if not fn then
        error(string.format("error loading module %q from file %q:\n\t%s", name, key, syntax_err), 2)
    end

    local ret = fn(...)

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
    local basename = path.basename(entrypoint)

    local new_module = setmetatable({
        bundled = is_bundled,
        file = entrypoint,
        dir = dirname,
        root = dirname,
        project = dirname,
    }, Module_meta)

    return new_module:import(basename)
end

return import
