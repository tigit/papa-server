function handle(data)
	local meta = {}

	for _,v in ipairs(data) do
		meta[v] = { v = 1, s = 1024 }
	end

	ngx.say(cjson.encode(meta))
end

return handle
