function handle(data)
    if 'task/ping.lua' == data then
        ngx.say(cjson.encode(
        {
            ['task/ping.lua'] = { v = 1, s = 254 },
        }
        ))
    else
        ngx.say(cjson.encode(
        {
            ['task/test.lua'] = { v = 1, s = 77 },
        }
        ))
    end
end

return handle
