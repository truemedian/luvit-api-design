local Buffer = import('Buffer')
local utils = import('utils')

---@class std.codec
local codec = {}

---@alias std.codec.reader fun(n: integer): string | nil, ...
---@alias std.codec.writer fun(buffer: string|nil): ...
---@alias std.codec.closer { read: boolean, write: boolean, err: string|nil, check: fun(), onClose: fun() }
---@alias std.codec.stream { read: std.codec.reader, write: std.codec.writer, closer: std.codec.closer }

---@alias std.codec.encoded_reader fun(): any
---@alias std.codec.encoded_writer fun(data: any)

---@alias std.codec.update_decoder fun(new: std.codec.decoder)
---@alias std.codec.update_encoder fun(new: std.codec.encoder)

---@alias std.codec.decoder fun(data: string): any, integer
---@alias std.codec.encoder fun(data: any): string

codec.http = import('http.lua')
codec.websocket = import('websocket.lua')

---@param read std.codec.reader
---@param decode std.codec.decoder
---@return std.codec.encoded_reader, std.codec.update_decoder
function codec.decoder(read, decode)
    return function()

    end, function(new)
        decode = new
    end
end

---@param write std.codec.writer
---@param encode std.codec.encoder
---@return std.codec.encoded_writer, std.codec.update_encoder
function codec.encoder(write, encode)
    return function(item)
        if item == nil then
            return write(nil)
        end

        return write(encode(item))
    end, function(new)
        encode = new
    end
end

---@param stream uv_stream_t
---@return std.codec.stream
function codec.wrapStream(stream)
    local closer = codec.wrapCloser(stream)

    local read = codec.wrapReader(stream, closer)
    local write = codec.wrapWriter(stream, closer)

    return {read = read, write = write, closer = closer}
end

---@param stream uv_stream_t
---@return std.codec.closer
function codec.wrapCloser(stream)
    local closer = {read = false, write = false, err = nil}

    local closed = false
    function closer.close()
        if closed then
            return
        end
        closed = true

        if not closer.readClosed then -- the wrapped reader must dispatch closure to all waiting threads
            closer.readClosed = true
            if closer.onClose then
                closer.onClose()
            end
        end

        if not stream:is_closing() then
            stream:close()
        end
    end

    function closer.check()
        if closer.err or (closer.read and closer.write) then
            closer.close()
        end
    end

    return closer
end

---@param stream uv_stream_t
---@param closer std.codec.closer
---@return std.codec.reader
function codec.wrapReader(stream, closer)
    ---@type std.Buffer
    local buffer = Buffer(128)

    local queue = {}
    local last = 1 -- one past the last element
    local first = 1 -- the next thread to resume
    local paused = true
    local done = false

    function closer.onClose()
        if not closer.read then
            closer.read = true

            for i = first, last - 1 do
                utils.assertResume(queue[i][1], nil, closer.err)

                queue[i] = nil
            end

            first = last
        end
    end

    local function dispatch(force)
        local item = queue[first]
        if item[3] then -- is this a peek
            local data

            if item[2] >= 0 then
                data = buffer:peek(item[2])
            end

            return utils.assertResume(item[1], data)
        end

        if #buffer >= item[2] or force then
            local data = buffer:read(item[2])

            queue[first] = nil
            first = first + 1

            return utils.assertResume(item[1], data)
        end
    end

    local function onRead(err, chunk)
        if err then
            closer.err = err
            return closer.check()
        end

        if chunk == nil then -- we've reached the end of the stream, no more data is coming
            done = true

            -- there is still at least one thread waiting
            while first <= (last - 1) and #buffer > 0 do
                dispatch(true)
            end

            if closer.read then
                return
            end
            closer.read = true

            return closer.check()
        else
            buffer:write(chunk)

            while first <= last - 1 do
                dispatch(false)
            end
        end

        if first == last then
            -- We've passed data to all of the waiting threads, but still have more, we can stop reading for now

            paused = true
            assert(stream:read_stop())
        end
    end

    return function(n) -- read
        if #buffer >= n then
            return buffer:read(n)
        elseif done and #buffer > 0 then
            return buffer:read()
        end

        if done then
            return nil
        end

        if paused then
            paused = false
            assert(stream:read_start(onRead))
        end

        queue[last] = {coroutine.running(), n}
        last = last + 1

        return coroutine.yield()
    end
end

---@param stream uv_stream_t
---@param closer std.codec.closer
---@return std.codec.writer
function codec.wrapWriter(stream, closer)
    return function(chunk)
        if closer.write then
            return nil, 'already shutdown'
        end

        local wait = utils.waitCallback(coroutine.running())

        if chunk == nil then
            closer.write = true
            closer.check()

            local success, err = stream:shutdown(wait)
            if not success then
                return nil, err
            end

            err = coroutine.yield()
            return not err, err
        end

        local success, err = stream:write(chunk, wait)
        if not success then
            closer.err = err
            closer.check()

            return not err, err
        end

        err = coroutine.yield()

        if err then
            closer.err = err
            closer.check()
        end

        return not err, err
    end
end

return codec
