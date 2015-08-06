local ping = {
    _stat = 0,
    _start = 0,
}

function ping:start(data)
    self._start = os.time()
    log:debug('ping', 'start', tostring(data))
end

function ping:update(time)
    if 0 == self._stat then
        --loop:push('task/file/list', { id = 123, path = 'task' })
        
        loop:push('task/test', { id = 123 })
        self._stat = 1
    end

    if os.time() - self._start > 2 then
        cbind.call('loop.restart')
    end

    return loop.TS_FINE
end

function ping:stop()
    log:debug('ping', 'stop')
end

return ping
