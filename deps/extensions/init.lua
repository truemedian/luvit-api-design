
---@class std.extensions
local extensions = {}

extensions.math = import 'math.lua'
extensions.string = import 'string.lua'
extensions.table = import 'table.lua'

function extensions.load()
    for name, ext in pairs(extensions) do
        if name ~= 'load' then
            for fn_name, fn in pairs(ext) do
                _G[name][fn_name] = fn
            end
        end
    end
end

return extensions