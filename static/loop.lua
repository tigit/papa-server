loop = {
    _TS_FINE = 0,
    _TS_DONE = 1,
    _TS_EXIT = 2
}

function loop:__on_update_file(file, key, ret)
    print('loop:__on_update_file ' .. file .. ', ' .. tostring(ret))

    local f = self._file_list[file]
    if 3 == f.s and cfile.check(file, f.s, f.v) then
        f.s = 4
    else 
        f.s = 0 
        f.e = (f.e or 0) + 1
    end
end

function loop:__update_file(file)
    print('loop:__update_file ' .. file)

    local f = self._file_list[file]
    if cfile.check(file, f.s, f.v) then
        f.s = 4
    else
        chttp:file(DATA.config.static_url .. file, file, f.v, function(...) self:__on_update_file(file, ...) end)
        f.s = 3
    end
end

function loop:__on_fetch_file(file, key, ret)
    print('loop:__on_fetch_file ' .. file .. ', ' .. ret)

    local e = true

    local r = cjson.decode(ret)
    if r then
        for k,v in pairs(r) do
            local f = self._file_list[k]
            if not f or v.v ~= f.v or v.s ~= f.s then
                self._file_list[k] = v e = false
            elseif k == file then
                f.s = 2 e = false
            end
        end
    end

    if e then
        local f = self._file_list[file]
        f.s = 0 f.e = (f.e or 0) + 1
    end
end

function loop:__check_file()
    for k,v in pairs(self._file_list) do 
        if not v.s or 0 == v.s then
            chttp:post(DATA.config.server_url, cjson.encode({tick = "file_info", data = k}), function(...) self:__on_fetch_file(k, ...) end)
            v.s = 1
        elseif 2 == v.s then
            self:__update_file(k)
        end
    end
end

function loop:__on_fetch_task(task, key, ret)
    print('loop:__on_fetch_task ' .. task .. ', ' .. tostring(ret))
    local e = true

    local r = cjson.decode(ret)
    if r then
        for k,v in pairs(r) do
            print('loop:__on_fetch_task 1 ' .. k .. ', ' .. tostring(v))
            local t = self._task_list[k]
            if not t or t.v ~= v.v then
                for k1,v1 in pairs(v.f) do
                    if not self._file_list[v1] then
                        self._file_list[v1] = {}
                    end
                end
                self._task_list[k] = v e = false
            elseif k == task then
                t.s = 2 e = false
            end
        end
    end

    if e then
        local t = self._task_list[task]
        t.s = 0 t.e = (t.e or 0) + 1
    end
end

function loop:__resume_task(task)
    if task.l then
        for k,v in pairs(task.l) do
            local r = task.c()
            table.insert(v.t, { r = r })
            if r.start then
                r:start(v.d)
            end
        end
    end
end

function loop:__check_task()
    for k,v in pairs(self._task_list) do 
        print('loop:__check_task ' .. k)
        if not v.c then
            if not v.s or 0 == v.s then
                chttp:post(DATA.config.server_url, cjson.encode({tick = "task_info", data = k}), function(...) self:__on_fetch_task(k, ...) end)
                v.s = 1
            elseif 2 == v.s then
                local ok = true
                for k,v in pairs(v.f) do
                    local f = self._file_list[v]
                    if not f.s or 3 ~= f.s then
                        ok = false
                        break
                    end
                end
                if ok then
                    v.c = loadfile(HOME .. v.f[1])
                    if not v.c then
                        v.s = 0
                        v.e = (v.e or 0) + 1
                    else
                        self:__resume_task(task)
                    end
                end
            end
        end
    end
end

function loop:__run_task(list, task, data)
    local t = self._task_list[task]
    if t and t.c then
        local r = t.c()
        table.insert(list, { r = r })
        if r.start then
            r:start(data)
        end
    else
        if not t then
            t = { l = {} }
            self._task_list[task] = t
        end
        table.insert(t.l, { t = list, d = data })
    end
end

function loop:start()
    print('loop:start ')

    self._file_list = {}

	self._task_list = {}
    self._push_list = {}
    self._post_list = {}

    self:push('task/ping')
end

function loop:stop()
    local h = self._push_list[1]
    if h and h.r.stop then
        h.r:stop()
    end
    self._push_list = {}

    for i = #self._post_list, 1, -1 do
        local t = self._post_list[i]
        if t and t.r.stop then
            t.r:stop()
        end
    end
    self._post_list = {}
end

function loop:update()
    print('loop:update')

    self:__check_file()
    self:__check_task()

    local time = os.time()

    local h = self._push_list[1]
    if h and h.r.update then
        local st = h.r:update(time)
        if self._TS_FINE ~= st then
            if h.r.stop then
                h.r:stop()
            end
            table.remove(self._push_list, 1)
            if self._TS_EXIT == st then
                bind:call('loop.restart')
            end
        end
    end

    for i = #self._post_list, 1, -1 do
        local t = self._post_list[i]
        if not t then
            local st = self._TS_DONE
            if t.r.update then
                st = t.r:update(time)
            end
            if self._TS_FINE ~= st then
                if t.r.stop then
                    t.r:stop()
                end
                table.remove(self._post_list, i)
                if self._TS_EXIT == st then
                    bind:call('loop.restart')
                end
            end
        end
    end
end

function loop:event(type, data, sign)
    local h = self._push_list[1]
    if h and h.r.event then
        if h.r:event(type, data, sign) then
            return
        end
    end

    for i = #self._post_list, 1, -1 do
        local t = self._post_list[i]
        if t and t.r.event then
            if t.r:event(type, data, sign) then
                break
            end
        end
    end
end

function loop:push(task, data)
    self:__run_task(self._push_list, task, data)
end

function loop:post(task, data)
    self:__run_task(self._post_list, task, data)
end

function cbind.loop()
    loop:update()
end
function cbind.stop()
    loop:stop()
end
function cbind.event(type, data, sign)
    loop:event(type, data, sign)
end
cbind:bind()

loop:start()
