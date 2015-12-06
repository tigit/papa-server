io.output(io.open(sdata.dir_log .. '/push.log', 'a'))
io.write(ngx.req.get_body_data())
