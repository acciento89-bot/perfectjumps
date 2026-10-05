local task = require("@lune/task")
local MutationGate = require("../src/shared/security/MutationGate")

return function()
	local gate = MutationGate.new(function()
		task.wait()
	end)
	local order = {}
	local completed = 0

	task.spawn(function()
		gate:Run("player", function()
			table.insert(order, "first-start")
			task.wait(0.03)
			table.insert(order, "first-end")
		end)
		completed += 1
	end)

	task.spawn(function()
		task.wait(0.005)
		gate:Run("player", function()
			table.insert(order, "second")
		end)
		completed += 1
	end)

	local deadline = os.clock() + 1
	while completed < 2 and os.clock() < deadline do
		task.wait()
	end

	assert(completed == 2, "serialized mutations did not complete")
	assert(table.concat(order, ",") == "first-start,first-end,second", "same-key mutations overlapped or reordered")

	local ok = pcall(function()
		gate:Run("player", function()
			error("expected")
		end)
	end)
	assert(ok == false, "mutation callback errors must propagate")

	local released = false
	gate:Run("player", function()
		released = true
	end)
	assert(released, "gate remained locked after callback error")
end
