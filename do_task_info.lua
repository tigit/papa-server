function handle(data)
    ngx.say(cjson.encode(
    {
        ['task/ping'] = {
            v = 0,
            f = {
                [1] = 'task/ping.lua',
                [2] = 'task/test.lua',
            }
        },
    }
    ))
end

return handle
