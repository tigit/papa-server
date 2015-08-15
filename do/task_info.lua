function handle(data)
    local file = data .. '.lua'
    local attr = lfs.attributes('/data/www/static/daemon/' .. file)
    return ngx.say(cjson.encode(
    {
        [data] = {
            v = attr.modification,
            f = {
                [1] = file,
            }
        },
    }
    ))
end

return handle