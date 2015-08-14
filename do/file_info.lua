function handle(data)
    local attr = lfs.attributes('/data/www/static/daemon/' .. data)
    return ngx.say(
    cjson.encode({[data] = {v = attr.modification, s = attr.size}})
    )
end

return handle
