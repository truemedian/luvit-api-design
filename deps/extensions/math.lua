---@class std.extensions.math
local ext_math = {}

-- This is a polyfill for 5.1, which does not support passing the base to math.log.
if math.log(100, 10) ~= 2 then
    function math.log(n, base)
        if base then
            return math.log(n) / math.log(base)
        else
            return math.log(n)
        end
    end
end

---A value that is never equal to itself.
---@see isnan
ext_math.nan = 0 / 0

---Euler's number. This is the base of the natural logarithm.
---@see math.log
ext_math.e = math.exp(1)

---Returns `num` clamped to [minValue, maxValue].
---@param num number
---@param minValue number
---@param maxValue number
---@return number
function ext_math.clamp(num, minValue, maxValue)
    return math.min(math.max(num, minValue), maxValue)
end

---Returns `num` rounded normally to `precision` decimals of precision.
---@param num number
---@param precision? number
---@return number
function ext_math.round(num, precision)
    local m = 10 ^ (precision or 0)
    return math.floor(num * m + 0.5) / m
end

---Returns -1 for a negative number, 1 for a positive number and 0 for 0.
---@param n number
---@return number
function ext_math.sign(n)
    return n > 0 and 1 or n == 0 and 0 or -1
end

---Returns the cube root of `n`.
---@param n number
---@return number
function ext_math.cbrt(n)
    return n ^ (1 / 3)
end

---Returns the `base`th root of `n`.
---@param n number
---@param base number
---@return number
function ext_math.root(n, base)
    if base < 1 or n % 2 == 0 and n < 0 then
        return ext_math.nan
    end

    return n ^ (1 / base)
end

---Returns true if `n` is nan.
---@param n number
---@return boolean
function ext_math.isnan(n)
    return n ~= n
end

return ext_math
