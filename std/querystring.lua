---@class std.querystring
local querystring = {}

---@param tbl table
---@param separator_char? string
---@param equals_char? string
---@return string
function querystring.encode(tbl, separator_char, equals_char) end

---@param str string
---@param separator_char? string
---@param equals_char? string
---@return table
function querystring.decode(str, separator_char, equals_char) end

return querystring
