---@class urilib
local urilib = {}

---@alias uri_t { scheme: string, authority?: string, userinfo?: string, hostname?: string, port?: number, path: string, query?: string|table<string, string>, fragment?: string }

---@param uri string
---@param parse_querystring boolean
---@return uri_t
function urilib.parse(uri, parse_querystring) end

---@param info uri_t
---@return string
function urilib.format(info) end

return urilib
