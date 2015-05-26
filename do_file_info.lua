function handle(data)
    local attr = lfs.attributes('./server/static/' .. data)
    return ngx.say(
    cjson.encode({[data] = {v = attr.modification, s = attr.size}})
    )
end

return handle
