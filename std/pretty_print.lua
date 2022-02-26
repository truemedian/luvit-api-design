---@class Theme
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
local _Theme = {}

---@alias uv_stream_t userdata

---@class pretty_printlib
---@field themes table<integer, Theme>
---@field current_theme Theme
---@field stdin uv_stream_t
---@field stdout uv_stream_t
---@field stderr uv_stream_t
local pretty_print = {} -- TODO: Come up with a better name

--- Functions that print something

---@vararg string
function pretty_print.prettyPrint(...) end

---@vararg string
function pretty_print.print(...) end

-- Functions that transform strings

---@param str string
---@param depth? integer
---@param no_color? boolean
---@return string
function pretty_print.dump(str, depth, no_color) end

---@param str string
---@return string
function pretty_print.strip(str) end

---@param color_name string
---@return string
function pretty_print.color(color_name) end

---@param str string
---@param color_name string
---@param reset_name string
---@return string
function pretty_print.colorize(str, color_name, reset_name) end

--- Functions that modify the current theme

---@param theme Theme|integer
function pretty_print.setTheme(theme) end

return pretty_print
