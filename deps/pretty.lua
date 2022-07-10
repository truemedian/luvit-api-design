---@class std.pretty
---@field escape_sequences table
---@field current_theme Theme
---@field stdin uv_stream_t
---@field stdout uv_stream_t
---@field stderr uv_stream_t
local pretty = {}

---@alias uv_stream_t userdata

pretty.escape_sequences = {
    reset = '0',
    bold = '1',
    faint = '2',
    italic = '3',
    underline = '4',
    blink = '5',
    invert = '7',

    not_intense = '22',
    not_italic = '23',
    not_underline = '24',
    not_blink = '25',
    not_invert = '27',

    foreground = {
        black = '30',
        red = '31',
        green = '32',
        yellow = '33',
        blue = '34',
        magenta = '35',
        cyan = '36',
        white = '37',

        default = '39',

        bright_black = '90',
        bright_red = '91',
        bright_green = '92',
        bright_yellow = '93',
        bright_blue = '94',
        bright_magenta = '95',
        bright_cyan = '96',
        bright_white = '97',
    },

    background = {
        black = '40',
        red = '41',
        green = '42',
        yellow = '43',
        blue = '44',
        magenta = '45',
        cyan = '46',
        white = '47',

        default = '49',

        bright_black = '100',
        bright_red = '101',
        bright_green = '102',
        bright_yellow = '103',
        bright_blue = '104',
        bright_magenta = '105',
        bright_cyan = '106',
        bright_white = '107',
    },
}

---@class Theme
local default_theme = {
    property = '37', -- white
    sep = '90', -- bright-black
    braces = '90', -- bright-black

    ['nil'] = '90', -- bright-black
    boolean = '33', -- yellow
    number = '93', -- bright-yellow
    string = '32', -- green
    quotes = '92', -- bright-green
    escape = '92', -- bright-green
    ['function'] = '35', -- purple
    thread = '95', -- bright-purple

    table = '94', -- bright blue
    userdata = '96', -- bright cyan
    cdata = '36', -- cyan

    err = '91', -- bright red
    success = '93;42', -- bright-yellow on green
    failure = '93;41', -- bright-yellow on red
    highlight = '96;44', -- bright-cyan on blue
}

pretty.current_theme = default_theme

--- Functions that print something

---@vararg string
function pretty.prettyPrint(...) end

---@vararg string
function pretty.print(...) end

-- Functions that transform strings

---@param str string
---@param depth? integer
---@param no_color? boolean
---@return string
function pretty.dump(str, depth, no_color) end

---@param str string
---@return string
function pretty.strip(str) end

---@param color_name string
---@return string
function pretty.color(color_name) end

---@param str string
---@param color_name string
---@param reset_name string
---@return string
function pretty.colorize(str, color_name, reset_name) end

--- Functions that modify the current theme

---@param theme Theme
function pretty.setTheme(theme) end

return pretty
