---@class std.uri
local uri = {}

---@alias uri_info { scheme: string, authority?: string, userinfo?: string, hostname?: string, port?: number, path: string, query?: string, fragment?: string }

---@param str string
---@return string
function uri.percentEncode(str)
    error('not yet implemented')
end

---@param str string
---@return string
function uri.percentDecode(str)
    error('not yet implemented')
end

---@param info uri_info
---@return string
function uri.encode(info)
    error('not yet implemented')
end

---@param str string
---@return uri_info
function uri.decode(str)
    error('not yet implemented')
end

return uri
