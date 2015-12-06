local function handle(data)
    local attr = lfs.attributes(sdata.dir_static .. '/' .. data)
    return ngx.say(
    cjson.encode({[data] = {v = attr.modification, s = attr.size}})
    )
end

return handle
