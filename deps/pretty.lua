local uv = require 'uv'

---@class std.pretty
---@field stdin uv_stream_t|nil
---@field stdout uv_stream_t|nil
---@field stderr uv_stream_t|nil
---@field width integer
---@field use_colors boolean
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

pretty.indent_string = '    '
pretty.default_max_depth = 8

--- Functions that print something

---@vararg any
function pretty.prettyPrint(...)
    if pretty.stdout == nil then return end

    local n = select('#', ...)

    for i = 1, n - 1 do
        local str = pretty.dump((select(i, ...)))

        uv.write(pretty.stdout, str)
        uv.write(pretty.stdout, '\t')
    end

    if n > 0 then
        local str = pretty.dump(select(n, ...), pretty.default_max_depth, not pretty.use_colors)
        uv.write(pretty.stdout, str)
    end

    uv.write(pretty.stdout, '\n')
end

---@vararg string
function pretty.print(...)
    if pretty.stdout == nil then return end

    local n = select('#', ...)

    for i = 1, n - 1 do
        local str = tostring(select(i, ...))

        uv.write(pretty.stdout, str)
        uv.write(pretty.stdout, '\t')
    end

    if n > 0 then
        local str = tostring(select(n, ...))
        uv.write(pretty.stdout, str)
    end

    uv.write(pretty.stdout, '\n')
end

-- Functions that transform strings

---@param str string
---@return string
function pretty.strip(str)
    return (string.gsub(str, '\27%[[^m]*m', ''))
end

---@param color_name? string
---@return string
function pretty.color(color_name)
    if color_name == nil then -- these are the codes to reset foreground and background.
        return '\27[39;49m'
    else
        return '\27[' .. (pretty.current_theme[color_name] or '0') .. 'm'
    end
end

---@param str string
---@param color_name string
---@param reset_name? string
---@param force_color? boolean
---@return string
function pretty.colorize(str, color_name, reset_name, force_color)
    if pretty.use_colors or force_color then
        if reset_name == nil then
            return pretty.color(color_name) .. tostring(str)
        else
            return pretty.color(color_name) .. tostring(str) .. pretty.color(reset_name)
        end
    else
        return tostring(str)
    end
end

-- Definitions required for dump

local character_escapes = {}

local single_quote1 = pretty.colorize("'", 'quotes', 'string', true)
local single_quote2 = pretty.colorize("'", 'quotes', nil, true)
local double_quote1 = pretty.colorize('"', 'quotes', 'string', true)
local double_quote2 = pretty.colorize('"', 'quotes', nil, true)
local open_brace = pretty.colorize('{', 'braces', nil, true)
local clos_brace = pretty.colorize('}', 'braces', nil, true)
local open_bracket = pretty.colorize('[', 'property', nil, true)
local clos_bracket = pretty.colorize(']', 'property', nil, true)
local comma = pretty.colorize(', ', 'sep', nil, true)
local equals = pretty.colorize(' = ', 'sep', nil, true)
local zero = pretty.colorize('0', 'number', nil, true)
local star = pretty.colorize('*', 'sep', nil, true)

for i = 0, 31 do
    character_escapes[i] = pretty.colorize(string.format('\\%03d', i), 'escape', 'string', true)
end

character_escapes[7] = pretty.colorize('\\a', 'escape', 'string', true)
character_escapes[8] = pretty.colorize('\\b', 'escape', 'string', true)
character_escapes[9] = pretty.colorize('\\t', 'escape', 'string', true)
character_escapes[10] = pretty.colorize('\\n', 'escape', 'string', true)
character_escapes[11] = pretty.colorize('\\v', 'escape', 'string', true)
character_escapes[12] = pretty.colorize('\\f', 'escape', 'string', true)
character_escapes[13] = pretty.colorize('\\r', 'escape', 'string', true)

character_escapes[34] = pretty.colorize('\\"', 'escape', 'string', true)
character_escapes[39] = pretty.colorize("\\'", 'escape', 'string', true)
character_escapes[92] = pretty.colorize('\\\\', 'escape', 'string', true)

for i = 128, 255 do
    character_escapes[i] = pretty.colorize(string.format('\\%03d', i), 'escape', 'string', true)
end

---@param thing any
---@param depth? number
---@param no_color? boolean
---@return string
function pretty.dump(thing, depth, no_color)
    if depth == nil then
        depth = math.huge
    end

    local seen = {}
    local function preprocess(value, cur_depth)
        local typ = type(value)

        if typ == 'string' then
            if string.find(value, "'", 1, true) and not string.find(value, '"', 1, true) then
                local escaped = string.gsub(value, '[\\%c\128-\255]', character_escapes)

                return double_quote1 .. escaped .. double_quote2
            else
                local escaped = string.gsub(value, "[\\'%c\128-\255]", character_escapes)

                return single_quote1 .. escaped .. single_quote2
            end
        elseif typ == 'table' and not seen[value] and cur_depth < depth then
            seen[value] = true

            local total = 0
            for _ in pairs(value) do total = total + 1 end

            local ret = {}
            ret.integral = {}

            ret.name = pretty.colorize(tostring(value), typ, nil, true)
            ret.has_metatable = getmetatable(value) ~= nil

            local i = 1
            for k, v in pairs(value) do
                local pair = {}
                ret[i] = pair

                if type(k) == 'string' and string.find(k, '^[_%a][_%a%d]*$') then
                    pair.key = pretty.colorize(k, 'property', nil, true)
                else
                    pair.key = preprocess(k, cur_depth + 1)
                    pair.key_enclose = true
                end

                pair.value = preprocess(v, cur_depth + 1)

                if type(k) == 'number' and math.floor(k) == k then
                    ret.integral[k] = pair
                end

                i = i + 1
            end

            return ret
        else
            return pretty.colorize(tostring(value), typ, nil, true)
        end
    end

    local buffer = {}
    local offset = 0
    local cur_indent = 0
    local last_batch = 1

    local function write(str, start_batch)
        if start_batch then
            last_batch = #buffer + 1
        end

        local len = #pretty.strip(str)

        if len < pretty.width - offset then
            table.insert(buffer, str)

            offset = offset + len
        else
            table.insert(buffer, last_batch, '\n')
            table.insert(buffer, last_batch + 1, string.rep(pretty.indent_string, cur_indent))
            table.insert(buffer, str)

            local batch_len = 0

            for i = last_batch + 1, #buffer do
                batch_len = batch_len + #pretty.strip(buffer[i])
            end

            offset = (#pretty.indent_string * cur_indent + batch_len) % pretty.width
        end
    end

    local function force_newline()
        table.insert(buffer, '\n')
        table.insert(buffer, string.rep(pretty.indent_string, cur_indent))

        offset = (#pretty.indent_string * cur_indent) % pretty.width
    end

    local function add_indent()
        cur_indent = cur_indent + 1

        force_newline()
    end

    local function rem_indent()
        cur_indent = cur_indent - 1

        force_newline()
    end

    local function process(value)
        if type(value) == 'table' then
            write('', true)

            if value.has_metatable then
                write(star)
            end

            write(value.name)

            write(' ')
            write(open_brace)
            add_indent()

            local ignore = {}

            if value.integral[0] then
                local pair = value.integral[0]
                ignore[pair] = true

                write(open_bracket, true)
                write(zero)
                write(clos_bracket)
                write(equals)
                process(pair.value)
                write(comma)
            end

            local i = 1
            while value.integral[i] do
                local pair = value.integral[i]
                ignore[pair] = true

                write('', true)
                process(pair.value)
                write(comma)

                i = i + 1
            end

            table.sort(value, function(a, b)
                if type(a.key) == 'table' and type(b.key) == 'table' then
                    return tostring(a.key) < tostring(b.key)
                elseif type(a.key) == 'table' then
                    return false
                elseif type(b.key) == 'table' then
                    return true
                end

                if type(a.value) == type(b.value) then
                    return a.key < b.key
                elseif type(a.value) == 'table' then
                    return false
                elseif type(b.value) == 'table' then
                    return true
                end
            end)

            for j, pair in ipairs(value) do
                if not ignore[pair] then
                    if type(pair.value) == 'table' then
                        force_newline()
                    end

                    write('', true)
                    if pair.key_enclose then
                        write(open_bracket)
                        process(pair.key)
                        write(clos_bracket)
                    else
                        process(pair.key)
                    end

                    write(equals)

                    process(pair.value)

                    if j < #value then
                        write(comma)
                    end
                end
            end

            rem_indent()
            write(clos_brace)
        else
            write(value)
        end
    end

    local colorized = preprocess(thing, 0)
    process(colorized)

    local str = table.concat(buffer)

    if no_color then
        return pretty.strip(str)
    else
        return str .. pretty.color(nil)
    end
end

--- Functions that modify the current theme

---@param theme Theme
function pretty.setTheme(theme)
    pretty.current_theme = theme
end

-- Set up stdio, this breaks the `io` library

if uv.guess_handle(0) == 'tty' then
    pretty.stdin = uv.new_tty(0, true)
else
    pretty.stdin = uv.new_pipe(false)
    uv.pipe_open(pretty.stdin, 0)
end

if uv.guess_handle(1) == 'tty' then
    pretty.stdout = uv.new_tty(1, false)
    pretty.width = uv.tty_get_winsize(pretty.stdout)

    if pretty.width == 0 then
        pretty.width = 80
    end

    pretty.use_colors = true
else
    pretty.stdout = uv.new_pipe(false)
    uv.pipe_open(pretty.stdout, 1)

    pretty.width = 80
    pretty.use_colors = false
end

if uv.guess_handle(2) == 'tty' then
    pretty.stderr = uv.new_tty(2, false)
else
    pretty.stderr = uv.new_pipe(false)
    uv.pipe_open(pretty.stderr, 2)
end

_G.print = pretty.print
_G.pprint = pretty.prettyPrint

return pretty
