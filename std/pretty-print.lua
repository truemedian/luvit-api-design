---@class theme
---@field property string
---@field sep string
---@field braces string
---@field nil string
---@field boolean string
---@field number string
---@field string string
---@field quotes string
---@field escape string
---@field function string
---@field thread string
---@field table string
---@field userdata string
---@field cdata string
---@field err string
---@field success string
---@field failure string
---@field highlight string
local _theme = {}

---@alias uv_stream_t userdata

---@class prettyprintlib
---@field themes table<integer, theme>
---@field currentTheme theme
---@field stdin uv_stream_t
---@field stdout uv_stream_t
---@field stderr uv_stream_t
local prettyPrint = {}

--- Functions that print something

---@vararg string
function prettyPrint.prettyPrint(...) end

---@vararg string
function prettyPrint.print(...) end

-- Functions that transform strings

---@param str string
---@param depth? integer
---@param noColor? boolean
---@return string
function prettyPrint.dump(str, depth, noColor) end

---@param str string
---@return string
function prettyPrint.strip(str) end

---@param colorName string
---@return string
function prettyPrint.color(colorName) end

---@param str string
---@param colorName string
---@param resetName string
---@return string
function prettyPrint.colorize(str, colorName, resetName) end

--- Functions that modify the current theme

---@param theme theme|integer
function prettyPrint.setTheme(theme) end

return prettyPrint
