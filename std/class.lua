---@class std.class
local class = {}

---@alias class any

local class_meta = {}

function class_meta:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function class_meta:__tostring() return 'class ' .. self.__name end

local function protectedNewIndex(obj, field, value)
    if field:sub(1, 2) == '__' then
        return error('attempt to set a protected field "' .. field .. '"')
    else
        rawset(obj, field, value)
    end
end

---@param cls class
---@return boolean
function class.isClass(cls) return getmetatable(cls) == class_meta end

---@param obj any
---@param cls class
---@return boolean
function class.instanceOf(obj, cls)
    local meta = getmetatable(obj)

    while meta do
        if meta == cls then
            return true
        end

        meta = meta.__super
    end

    return false
end

---@param name string
---@param super class
---@return class
function class.create(name, super)
    assert(type(name) == 'string', 'name must be a string')
    assert(super == nil or class.isClass(super), 'super must be a class')

    local cls = setmetatable({}, class_meta)

    if super then
        for k, v in pairs(super) do
            cls[k] = v
        end
    end

    cls.__name = name
    cls.__super = super

    cls.__index = cls
    cls.__newindex = protectedNewIndex

    return cls
end

return class
