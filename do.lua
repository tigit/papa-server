local msg = cjson.decode(ngx.req.get_body_data())

if msg and msg.tick then
	local handle = require("server/do/" .. msg.tick)
	if handle then
		handle(msg.data)
	end
end
