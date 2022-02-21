---@class querystringlib
local querystring = {}

---@param str string
---@return string
function querystring.urlencode(str) end

---@param str string
---@return string
function querystring.urldecode(str) end

---@param table table
---@param separator_char? string
---@param equals_char? string
---@return string
function querystring.stringify(table, separator_char, equals_char) end

---@param str string
---@param separator_char? string
---@param equals_char? string
---@return table
function querystring.parse(str, separator_char, equals_char) end

return querystring
