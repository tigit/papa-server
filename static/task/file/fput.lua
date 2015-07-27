local ping = {
    _stat = 0
}

function ping:start(data)
    log:debug('ping', 'start', tostring(data))

    for file in cfile.dir('task') do
        log:debug(file)
        local attr = cfile.list('task/test/' .. file)
        log:debug(file, cjson.encode(attr))
    end
end

function ping:update(time)
    if 0 == self._stat then
        log:debug('ping', 'update', time)
        self._stat = 1
    end
    return loop.TS_FINE
end

function ping:stop()
    log:debug('ping', 'stop')
end

return ping
