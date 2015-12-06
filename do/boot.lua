local function handle(data)
    ngx.say(cjson.encode(
    {
        conf = {
            url_static = sdata.url_static,
            url_do = sdata.url_do,
            url_log = sdata.url_log,
        },
        loop = sutil:fread(sdata.dir_static_src .. '/loop.lua'),
    }
    ))
end

return handle
