---@class std.codec
local codec = {}

---@alias std.codec.reader function function() -> string
---@alias std.codec.writer function function(string) -> nil

---@alias std.codec.encoded_reader function function() -> any
---@alias std.codec.encoded_writer function function(any) -> nil

---@alias std.codec.decoder function function(string, integer) -> any, integer
---@alias std.codec.encoder function function(any) -> string

codec.http = require('std.codec.http')

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
