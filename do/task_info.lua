local function handle(data)
    local file = 'src/' .. data .. '.lua'
    local attr = lfs.attributes(sdata.dir_static .. '/' .. file)
    local list = {}
    sutil:fwalk(list, file)
    return ngx.say(cjson.encode(
    {
        [data] = {
            v = attr.modification,
            f = list,
        },
    }
    ))
end

return handle
