local test = {
    d = "test",
}
function test:start(data)
    cdata:save({ url = 'thedawens.net' })
    cdata:cache({ url = 'thedawens.net' })
    print(cdata.dev.id)
end

function test:update(time)
    return loop.TS_DONE
end

function test:stop()
    log:debug('file/list', 'stop')
end

return test
