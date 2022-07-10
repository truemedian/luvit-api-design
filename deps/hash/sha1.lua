---@class std.hash.Sha1
local Sha1 = require('std.class').create('std.hash.Sha1')

---@return std.hash.Sha1
function Sha1:init() end

---@param data string
function Sha1:update(data) end

---@return string
function Sha1:digest() end

---@param data string
---@return string
function Sha1:finish(data) end

return Sha1