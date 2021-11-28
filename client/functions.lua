FX.Functions = FX.Functions or {}

FX.Functions.EnumerateEntities = function(init, move, dispose)
	return coroutine.wrap(function()
		local iter, id = init()
		if not id or id == 0 then
			dispose(iter)
			return
		end

		local enum = {handle = iter, destructor = dispose}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next, id = move(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		dispose(iter)
    end)
end