function handle(data)
    io.output(io.open('./logs/task.log', 'a'))
    io.write(cjson.encode(data))
end

return handle
