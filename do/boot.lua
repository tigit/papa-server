function handle(data)
	print(sdata.url.static .. '/daemon/loop.lua')
	ngx.redirect(sdata.url.static .. '/daemon/loop.lua')
end

return handle
