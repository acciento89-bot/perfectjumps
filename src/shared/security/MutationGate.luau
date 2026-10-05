--!strict

local MutationGate = {}
MutationGate.__index = MutationGate

export type Gate = typeof(setmetatable({
	_busy = {} :: { [any]: boolean },
	_wait = function() end,
}, MutationGate))

function MutationGate.new(waitFunction: (() -> ())?): Gate
	return setmetatable({
		_busy = {},
		_wait = waitFunction or function()
			task.wait()
		end,
	}, MutationGate)
end

function MutationGate.Run(self: Gate, key: any, callback: () -> any): any
	while self._busy[key] do
		self._wait()
	end

	self._busy[key] = true
	local ok, result = pcall(callback)
	self._busy[key] = nil

	if not ok then
		error(result, 2)
	end
	return result
end

function MutationGate.Forget(self: Gate, key: any)
	self._busy[key] = nil
end

return MutationGate
