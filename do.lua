local msg = cjson.decode(ngx.req.get_body_data())

if msg and msg.task then
	local handle = require("server/do/" .. msg.task)
	if handle then
		handle(msg.data)
	end
end
