local list = {
    _stat = 0
}

function list:start(data)
    log:debug('file/list', 'start', tostring(data))

    local attr = cfile.list(data.path)
    chttp:post(cdata.pkg.config.server_url, cjson.encode({tick = "task_done", data = { arg = data, ret = attr}}))
end

function list:update(time)
    return loop.TS_DONE
end

function list:stop()
    log:debug('file/list', 'stop')
end

return list
