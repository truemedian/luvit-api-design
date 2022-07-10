---@class std.uri
local uri = {}

---@alias uri_info { scheme: string, authority?: string, userinfo?: string, hostname?: string, port?: number, path: string, query?: string, fragment?: string }

---@param str string
---@return string
function uri.percentEncode(str) end

---@param str string
---@return string
function uri.percentDecode(str) end

---@param info uri_info
---@return string
function uri.encode(info) end

---@param str string
---@return uri_info
function uri.decode(str) end

return uri
