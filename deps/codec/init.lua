---@class std.codec
local codec = {}

---@alias std.codec.reader fun(n: integer): string
---@alias std.codec.writer fun(buffer: string)

---@alias std.codec.encoded_reader fun(): any
---@alias std.codec.encoded_writer fun(data: any)

---@alias std.codec.decoder fun(data: string, offset: integer): any, integer
---@alias std.codec.encoder fun(data: any): string

codec.http = import('http.lua')
codec.websocket = import('websocket.lua')

---@param read std.codec.reader
---@param decode std.codec.decoder
---@return std.codec.encoded_reader
function codec.decoder(read, decode) end

---@param write std.codec.writer
---@param encode std.codec.encoder
---@return std.codec.encoded_writer
function codec.encoder(write, encode) end

---@param stream uv_stream_t
---@return std.codec.reader, std.codec.writer
function codec.wrapStream(stream) end

return codec
