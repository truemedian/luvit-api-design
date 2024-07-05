local class = import 'class'

local has_lj_buffer, lj_buffer = pcall(require, 'string.buffer')
local has_ffi, ffi = pcall(require, 'ffi')

local C
if has_ffi then
    ffi.cdef([[
       void *malloc(size_t size);
       void free(void *ptr);
       void *realloc(void *ptr, size_t size);

       void *memmove(void *dest, const void *src, size_t n);
    ]])

    -- avoids issues when statically linked on windows
    C = ffi.os == 'Windows' and ffi.load('msvcrt') or ffi.C
end

---@class std.Buffer
local Buffer = class.create('std.Buffer')

---Creates a new Buffer
---@param size? integer
function Buffer:init(size)
    error('not implemented')
end

---Resets a buffer to zero, does not deallocate memory
function Buffer:reset()
    error('not implemented')
end

-- Frees all memory associated with the buffer
function Buffer:free()
    error('not implemented')
end

---Defines the `#` operation
---@return integer
function Buffer:__len()
    error('not implemented')
end

---Writes data into the end of the buffer
---@param data string
function Buffer:write(data)
    error('not implemented')
end

---Reads data from the start of the buffer. If `n` is not provided, read all available data
---@param n? integer The number of bytes to read
---@return string
function Buffer:read(n)
    error('not implemented')
end

---Skips over data from the start of the buffer. If `n` is not provided, the entire contents
---of the buffer are removed.
---@param n? integer The number of bytes to skip
---@return string
function Buffer:skip(n)
    error('not implemented')
end

---Reads data from the start of the buffer without consuming it.
---@param n? integer The number of bytes to read
---@return string
function Buffer:peek(n)
    error('not implemented')
end

---@type std.Buffer
local impl

if has_lj_buffer then
    ---@class std.Buffer.LuajitBuffer : std.Buffer
    local LuajitBuffer = class.create('std.Buffer.LuajitBuffer', Buffer)
    function LuajitBuffer:init(size)
        self.buf = lj_buffer.new(size)
    end

    function LuajitBuffer:reset()
        self.buf:reset()
    end

    function LuajitBuffer:free()
        self.buf:free()
    end

    function LuajitBuffer:__len()
        return #self.buf
    end

    function LuajitBuffer:write(data)
        self.buf:put(data)
    end

    function LuajitBuffer:read(n)
        return self.buf:get(n)
    end

    function LuajitBuffer:skip(n)
        self.buf:skip(n)
    end

    function LuajitBuffer:peek(n)
        local ptr, len = self.buf:ref()

        local clamped = math.min(len, n or len)
        return ffi.string(ptr, clamped)
    end

    impl = LuajitBuffer
elseif has_ffi then
    ---@class std.Buffer.FfiBuffer : std.Buffer
    local FfiBuffer = class.create('std.Buffer.FfiBuffer', Buffer)
    function FfiBuffer:init(size)
        local typed_ptr

        if size ~= nil and size > 0 then
            local ptr = C.malloc(size)
            if ptr == nil then
                return error('not enough memory')
            end

            typed_ptr = ffi.cast('unsigned char*', ptr)
            ffi.gc(typed_ptr, C.free)
        else
            size = 0
        end

        self.ptr = typed_ptr
        self.capacity = size
        self.start = 0
        self.len = 0
    end

    function FfiBuffer:reset()
        self.start = 0
        self.len = 0
    end

    function FfiBuffer:free()
        C.free(ffi.gc(self.ptr, nil))

        self.ptr = nil
        self.capacity = 0
        self.start = 0
        self.len = 0
    end

    function FfiBuffer:__len()
        return self.len
    end

    function FfiBuffer:_rebase()
        if self.ptr + self.len < self.ptr + self.start then
            ffi.copy(self.ptr, self.ptr + self.start, self.len)
        else
            C.memmove(self.ptr, self.ptr + self.start, self.len)
        end

        self.start = 0
    end

    function FfiBuffer:_ensureCapacity(required_capacity)
        if self.capacity < required_capacity then
            local ptr, new_capacity
            if self.capacity == 0 then
                new_capacity = 1
                repeat
                    new_capacity = new_capacity * 2 + 1
                until new_capacity >= required_capacity

                ptr = C.malloc(new_capacity)
                if ptr == nil then
                    return error('not enough memory')
                end
            else
                if self.start > 0 then
                    self:_rebase()
                end

                new_capacity = self.capacity
                repeat
                    new_capacity = new_capacity * 2 + 1
                until new_capacity >= required_capacity

                ptr = C.realloc(self.ptr, new_capacity)
                if ptr == nil then
                    return error('not enough memory')
                end
            end

            local typed_ptr = ffi.cast('unsigned char*', ptr)
            ffi.gc(typed_ptr, C.free)

            if self.ptr then
                ffi.gc(self.ptr, nil)
            end

            self.ptr = typed_ptr
            self.capacity = new_capacity
        end
    end

    function FfiBuffer:_ensureUnusedCapacity(required_space)
        return self:_ensureCapacity(self.len + required_space)
    end

    function FfiBuffer:write(data)
        self:_ensureUnusedCapacity(#data)
        ffi.copy(self.ptr + self.len, data, #data)
        self.len = self.len + #data
    end

    function FfiBuffer:read(n)
        n = math.min(n or self.len, self.len)
        if n <= 0 then
            return ''
        end

        local data = ffi.string(self.ptr, n)

        self.start = self.start + n
        self.len = self.len - n

        return data
    end

    function FfiBuffer:skip(n)
        n = math.min(n or self.len, self.len)
        if n <= 0 then
            return
        end

        self.start = self.start + n
        self.len = self.len - n
    end

    function FfiBuffer:seek(n)
        local clamped = math.min(self.len, n or self.len)

        return ffi.string(self.ptr + self.start, clamped)
    end

    impl = FfiBuffer
else
    ---@class std.Buffer.FallbackBuffer : std.Buffer
    local FallbackBuffer = class.create('std.Buffer.FallbackBuffer', Buffer)
    function FallbackBuffer:init(size)
        self.arr = {}
    end

    function FallbackBuffer:reset()
        self.arr = {}
    end

    function FallbackBuffer:free()
        self.arr = {}
    end

    function FallbackBuffer:__len()
        local len = 0
        for _, str in ipairs(self.arr) do
            len = len + #str
        end

        return len
    end

    function FallbackBuffer:write(data)
        table.insert(self.arr, data)
    end

    function FallbackBuffer:read(n)
        if n == nil then
            local data = table.concat(self.arr)

            self:reset()

            return data
        end

        local parts = {}
        local len = 0

        local str = self.arr[1]
        if str == nil then
            return ''
        end

        while len + #str < n do
            len = len + #str
            table.insert(parts, str)
            table.remove(self.arr, 1)

            str = self.arr[1]

            if str == nil then
                return table.concat(parts)
            end
        end

        local left = n - len
        table.insert(parts, str:sub(1, left))
        self.arr[1] = str:sub(left + 1)

        return table.concat(parts)
    end

    function FallbackBuffer:skip(n)
        if n == nil then
            self:reset()
        end

        self:read(n)
    end

    function FallbackBuffer:peek(n)
        if n == nil then
            return table.concat(self.arr)
        end

        local parts = {}
        local len = 0

        local i = 1
        local str = self.arr[1]
        if str == nil then
            return ''
        end

        while len + #str < n do
            len = len + #str
            table.insert(parts, str)

            str = self.arr[i]
            i = i + 1

            if str == nil then
                return table.concat(parts)
            end
        end

        local left = n - len
        table.insert(parts, str:sub(1, left))

        return table.concat(parts)
    end

    impl = FallbackBuffer
end

return impl
