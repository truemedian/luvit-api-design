---@class urilib
local urilib = {}

---@alias uri_t { scheme: string, authority?: string, userinfo?: string, hostname?: string, port?: number, path: string, query?: string|table<string, string>, fragment?: string }

---@param info uri_t
---@return string
function urilib.encode(info) end

---@param uri string
---@param parse_querystring boolean
---@return uri_t
function urilib.decode(uri, parse_querystring) end

return urilib
