local ping = {
}

function ping:start(data)
    print('ping:start ' .. tostring(data))
end

function ping:update(time)
    print('ping:update ' .. tostring(time))
end

function ping:stop()
    print('ping:stop ')
end

return ping
