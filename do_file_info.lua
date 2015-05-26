function handle(data)
    ngx.say(cjson.encode(
    {
        ['task/ping.lua'] = { v = 1, s = 254 },
        ['task/test.lua'] = { v = 1, s = 77 },
    }
    ))
end

return handle
