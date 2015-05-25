DATA = cjson.decode(bind.call("data.get_meta"))

function LUA_BIND(obj, fun)
	return function (...) fun(obj, ...) end
end

function cfile.read(path)
	local d = nil
	local f = io.open(HOME .. path, "rb")
	if f then
		d = f:read("*all")
		f:close()
	end
	return d
end

local boot = {
	_stat = 0,
}

function boot.callback(key, ret)
	print("boot.callback " .. string.len(ret))

	boot._stat = 0
	if ret then
		local f = load(ret)
		if "function" == type(f) then
			f()
		end
	end
end

function boot.connect()
	chttp:post(DATA.config.server_url, 
		cjson.encode({tick = "boot", data = { ver = DATA.version, auth = cjson.decode(cfile.read(DATA.config.auth_token)) }}), 
		boot.callback)

	boot._stat = 1
end

function boot.update()
	if 0 == boot._stat then
		boot.connect()
	end
end

function bind.loop()
	boot.update()
end

function bind.stop()
	print("bind.stop")
end

function bind.event(type, data, sign)
	print("bind.stop")
end

bind:bind()
print("bind.start")
