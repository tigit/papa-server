local function handle(data)
    io.output(io.open('log/task.log', 'a'))
    io.write(cjson.encode(data))
end

return handle
