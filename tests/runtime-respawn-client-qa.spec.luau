local fs = require("@lune/fs")

return function()
	local camera = fs.readFile("src/client/controllers/CameraController.luau")
	local input = fs.readFile("src/client/controllers/InputController.luau")
	local init = fs.readFile("src/client/init.client.luau")
	local qaPath = "src/client/controllers/RuntimeQaController.luau"

	assert(fs.isFile(qaPath), "client runtime QA controller missing")
	local qa = fs.readFile(qaPath)

	assert(string.find(camera, "function CameraController.qaState()", 1, true), "camera QA state missing")
	assert(string.find(input, "function InputController.qaState()", 1, true), "input QA state missing")
	assert(string.find(qa, '"respawn_camera_reset"', 1, true), "camera respawn runtime gate missing")
	assert(string.find(qa, '"respawn_input_reset"', 1, true), "input respawn runtime gate missing")
	assert(string.find(qa, "[PerfectJumpClientQA] COMPLETE", 1, true), "client runtime completion marker missing")
	assert(string.find(init, "RuntimeQaController.start()", 1, true), "client init must start runtime QA controller")
end
