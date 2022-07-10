local has_luvi, luvi = pcall(require, 'luvi')
local readfile

if has_luvi then
    readfile = luvi.bundle.readfile
else
    require('luv')

    package.loaded.uv = package.loaded.luv

    function readfile(path)
        local fd = io.open(path, "r")
        if fd == nil then return nil end

        local data = fd:read('*a')
        fd:close()

        return data
    end
end

local bootstrap_require_cache = {}

local content_import = readfile('deps/import.lua')
local content_fs = readfile('deps/fs/init.lua')
local content_fs_path = readfile('deps/fs/path.lua')

local function bootstrap_import(name, content)
    if bootstrap_require_cache[name] then
        return bootstrap_require_cache[name]
    end

    if not content then
        return error('bootstrap import: attempt to require unloaded module ' .. name)
    end

    local env = setmetatable({
        import = bootstrap_import,
    }, { __index = _G })

    local fn, err = load(content, 'bootstrap:/' .. name, 't', env)
    if not fn then
        error('bootstrap failure: syn: ' .. err)
    end

    local success, result = pcall(fn)

    if not success then
        error('bootstrap failure: run: ' .. result)
    end

    bootstrap_require_cache[name] = result

    return bootstrap_require_cache[name]
end

bootstrap_import('path.lua', content_fs_path)
bootstrap_import('fs/init.lua', content_fs)
local import = bootstrap_import('import.lua', content_import)

-- fs requires being wrapped in a coroutine
coroutine.wrap(function()
    import.new('init.lua', false)
end)()
