local utils = {}

function utils.assertResume(thread, ...)
    local success, err = coroutine.resume(thread, ...)
    if not success then
        error(debug.traceback(thread, err), 0)
    end
end

function utils.waitCallback(thread)
    return function(...)
        utils.assertResume(thread, ...)
    end
end

return utils
