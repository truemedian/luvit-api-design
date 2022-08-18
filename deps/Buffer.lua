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
    C = ffi.os == "Windows" and ffi.load("msvcrt") or ffi.C
end

local Buffer = import('class').create('std.Buffer')

if has_lj_buffer then
    function Buffer:init(size)
        self.buf = lj_buffer.new(size)
    end

    function Buffer:reset()
        self.buf:reset()
    end

    function Buffer:free()
        self.buf:free()
    end

    function Buffer:len()
        return #self.buf
    end

    function Buffer:write(data)
        self.buf:put(data)
    end

    function Buffer:read(n)
        return self.buf:get(n)
    end

    function Buffer:skip(n)
        self.buf:skip(n)
    end
elseif has_ffi then
    function Buffer:init(size)
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

    function Buffer:reset()
        self.start = 0
        self.len = 0
    end

    function Buffer:free()
        C.free(ffi.gc(self.ptr, nil))

        self.ptr = nil
        self.capacity = 0
        self.start = 0
        self.len = 0
    end

    function Buffer:len()
        return self.len
    end

    function Buffer:_rebase()
        if self.ptr + self.len < self.ptr + self.start then
            ffi.copy(self.ptr, self.ptr + self.start, self.len)
        else
            C.memmove(self.ptr, self.ptr + self.start, self.len)
        end

        self.start = 0
    end

    function Buffer:_ensureCapacity(required_capacity)
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

    function Buffer:_ensureUnusedCapacity(required_space)
        return self:_ensureCapacity(self.len + required_space)
    end

    function Buffer:write(data)
        self:_ensureUnusedCapacity(#data)
        ffi.copy(self.ptr + self.len, data, #data)
        self.len = self.len + #data
    end

    function Buffer:read(n)
        n = math.min(n or self.len, self.len)
        if n <= 0 then return "" end

        local data = ffi.string(self.ptr, n)

        self.start = self.start + n
        self.len = self.len - n

        return data
    end

    function Buffer:skip(n)
        n = math.min(n or self.len, self.len)
        if n <= 0 then return end

        self.start = self.start + n
        self.len = self.len - n
    end
else
    function Buffer:init(size)
        self.arr = {}
    end

    function Buffer:reset()
        self.arr = {}
    end

    function Buffer:free()
        self.arr = {}
    end

    function Buffer:len()
        local len = 0
        for _, str in ipairs(self.arr) do
            len = len + #str
        end

        return len
    end

    function Buffer:write(data)
        table.insert(self.arr, data)
    end

    function Buffer:read(n)
        if n == nil then
            local data = table.concat(self.arr)

            self:reset()

            return data
        end

        local parts = {}
        local len = 0

        local str = self.arr[1]
        if str == nil then return "" end

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

    function Buffer:skip(n)
        if n == nil then
            self:reset()
        end

        self:read(n)
    end
end

return Buffer
