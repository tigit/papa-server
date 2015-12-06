cjson = require 'cjson'
lfs = require 'lfs'

sdata = {
}

function sdata:init()
	self.dir_log = '/data/var/nginx/log'

	self.dir_static = '/data/www/static'
	self.dir_static_src = self.dir_static .. '/src'
	self.dir_static_www = self.dir_static .. '/www'
	self.dir_static_res = self.dir_static .. '/res'

	self.url_static = 'http://static.thedawens.net'
	self.url_static_src = self.url_static .. '/src'
	self.url_static_www = self.url_static .. '/www'
	self.url_static_res = self.url_static .. '/res'

	self.url_server = 'http://server.thedawens.net'
	self.url_do = self.url_server .. '/do'
	self.url_log = self.url_server .. '/log'
end

sdata:init()

sutil = {
}

function sutil:fread(path)
	local d = nil
	local f = io.open(path, 'rb')
	if f then
		d = f:read('*all')
		f:close()
	end
	return d
end

function sutil:fwrite(path, data)
    io.output(io.open(path, 'wb'))
    io.write(data)
    io.close()
end

function sutil:fwalk(list, file)
    if list[file] then return end
    table.insert(list, file)

    --ngx.log(ngx.ERR, 'fwalk file ' .. file)

    local text = self:fread(sdata.dir_static .. '/' .. file) 
    for v in string.gmatch(text, "require%s+'(.-)'") do
        self:fwalk(list, v .. '.lua')
    end
end
