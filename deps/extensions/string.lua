---@class std.extensions.string
local ext_string = {}

---Returns whether or not the string starts with `pattern`. Use `plain` if you want to match `pattern` literally.
---@param str string
---@param pattern string
---@param plain? boolean
---@return boolean
function ext_string.startswith(str, pattern, plain)
    return string.find(str, pattern, 1, plain) == 1
end

---Returns whether or not the string ends with `pattern`. Use `plain` if you want to match `pattern` literally.
---@param str string
---@param pattern string
---@param plain? boolean
---@return boolean
function ext_string.endswith(str, pattern, plain)
    if plain then
        return string.sub(str, -#pattern) == pattern
    else
        if pattern:sub(-1) == '$' then
            pattern = pattern .. '$'
        end

        return not not string.find(str, pattern, 1)
    end
end

local pattern_special = [[^$()%.[]*+-?]]
local pattern_match = '[' .. pattern_special:gsub('.', '%%%1') .. ']'

---Returns a new string with all Lua Pattern special characters escaped.
---@param str string
---@return string
function ext_string.patternescape(str)
    return (string.gsub(str, pattern_match, '%%%1'))
end

---Returns a new string with all leading and trailing whitespace removed.
---@param str string
---@return string
function ext_string.trim(str)
    return string.match(str, '^%s*(.-)%s*$')
end

---Returns a table of all elements of the string split on `delim`. Use `plain` if the delimiter provided is not a pattern.
---@param str string
---@param[opt] delim string
---@param[opt] plain boolean
---@return table
function ext_string.split(str, delim, plain)
    local ret = {}

    if not str or str == '' then
        return ret
    end

    if not delim or delim == '' then
        for i = 1, #str do
            ret[i] = string.byte(str, i)
        end

        return ret
    end

    local p = 1
    while true do
        local i, j = string.find(str, delim, p, plain)
        if not i then
            break
        end

        table.insert(ret, string.sub(str, p, i - 1))
        p = j + 1
    end

    table.insert(ret, string.sub(str, p))
    return ret
end

---Returns a string of `final_len` random characters in the byte-range of `[mn, mx]`. By default `mn = 0` and `mx = 255`.
---@param final_len number
---@param min_char? number
---@param max_char? number
---@return string
function ext_string.random(final_len, min_char, max_char)
    local ret = {}
    min_char = min_char or 0
    max_char = max_char or 255

    for _ = 1, final_len do
        table.insert(ret, string.char(math.random(min_char, max_char)))
    end

    return table.concat(ret)
end

---Returns the Levenshtein distance between the two strings. This is often referred as "edit distance".
---[Wikipedia "Levenshtein Distance"](https://en.wikipedia.org/wiki/Levenshtein_distance)
---@param str1 string
---@param str2 string
---@return number
function ext_string.levenshtein(str1, str2)
    if str1 == str2 then
        return 0
    end

    local len1 = #str1
    local len2 = #str2

    if len1 == 0 then
        return len2
    elseif len2 == 0 then
        return len1
    end

    local matrix = {}
    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end

    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = string.byte(str1, i) == string.byte(str2, j) and 0 or 1
            matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
        end
    end

    return matrix[len1][len2]
end

---Returns the Damerau-Levenshtein distance between the two strings. This is often referred as "edit distance".
---[Wikipedia "Damerau-Levenshtein Distance"](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
---@param str1 string
---@param str2 string
---@return number
function ext_string.dameraulevenshtein(str1, str2)
    if str1 == str2 then
        return 0
    end

    local len1 = #str1
    local len2 = #str2

    if len1 == 0 then
        return len2
    elseif len2 == 0 then
        return len1
    end

    local matrix = {}
    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end

    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = string.byte(str1, i) == string.byte(str2, j) and 0 or 1
            matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            if i > 1 and j > 1 and string.byte(str1, i) == string.byte(str2, j - 1) and string.byte(str1, i - 1) == string.byte(str2, j) then
                matrix[i][j] = math.min(matrix[i][j], matrix[i - 2][j - 2] + 1)
            end
        end
    end

    return matrix[len1][len2]
end

---Returns true if the subsequence can be found inside `str`.
---For example: `ggl` is a subsequence of `GooGLe`. (uppercase letters signify which letters form the subsequence).
---@param subseq string
---@param str string
---@return boolean
function ext_string.subsequencematch(subseq, str)
    local matches = 0

    for i = 1, #str do
        if string.byte(subseq, matches + 1) == string.byte(str, i) then
            matches = matches + 1
        end
    end

    return matches == #subseq
end

return ext_string
