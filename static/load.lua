loop = {
	_TS_FINE = 0,
	_TS_DONE = 1,
	_TS_EXIT = 2,
}

function loop:start()
	self._task_list = {}
end

function loop:stop()
	for i = #self._task_list, 1, -1 do
		local task = self._task_list[i]
		if nil ~= task and nil ~= task.stop then
			task:stop()
		end
	end

	self._task_list = {}
end

function loop:update()
	for i = #self._task_list, 1, -1 do
		local task = self._task_list[i]
		if nil ~= task then
			local status = self._TS_DONE
			if nil ~= task.update then
				status = task:update()
			end
			if self._TS_FINE ~= status then
				if nil ~= task.stop then
					task:stop()
				end
				table.remove(self._task_list, i)
				if self._TS_EXIT == status then
					bind:call("loop.restart")
				end
			end
		end
	end
end

function loop:event(type, data, sign)
	for i = #self._task_list, 1, -1 do
		local task = self._task_list[i]
		if nil ~= task and nil ~= task.event then
			if task:event(type, data, sign) then
				break
			end
		end
	end

	self._task_list = {}
end

function loop:run(task)
	if nil ~= task then
		table.insert(self._task_list, task)
		if nil ~= task.start then
			task:start()
		end
	end
end

function bind.loop()
	loop:update()
end
function bind.stop()
	loop:stop()
end
function bind.event(type, data, sign)
	loop:event(type, data, sign)
end
bind:bind()

loop:start()
