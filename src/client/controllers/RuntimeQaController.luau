--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local RuntimeQaConfig = require(shared.config.RuntimeQaConfig)

local CameraController = require(script.Parent.CameraController)
local InputController = require(script.Parent.InputController)

local RuntimeQaController = {}

local started = false
local verified = false

local function emit(name: string, passed: boolean, fields: any?)
	print(
		("[PerfectJumpClientQA] %s %s %s"):format(
			if passed then "PASS" else "FAIL",
			name,
			HttpService:JSONEncode(fields or {})
		)
	)
end

local function waitUntil(predicate: () -> boolean, timeout: number): boolean
	local deadline = os.clock() + timeout
	repeat
		if predicate() then
			return true
		end
		task.wait(0.05)
	until os.clock() >= deadline
	return predicate()
end

local function verifyRespawn(character: Model)
	if verified then
		return
	end

	local cameraPassed = waitUntil(function()
		if player.Character ~= character then
			return false
		end
		local state = CameraController.qaState()
		return state.Scriptable
			and state.SubjectIsCurrentHumanoid
			and state.SnappedToCurrentCharacter
			and state.HasCurrentPosition
			and state.HasTargetPosition
	end, 8)
	emit("respawn_camera_reset", cameraPassed, CameraController.qaState())

	local inputPassed = waitUntil(function()
		local state = InputController.qaState()
		return state.Charging == false and state.Phase == "Ready" and state.UiModal == false
	end, 8)
	emit("respawn_input_reset", inputPassed, InputController.qaState())

	if cameraPassed and inputPassed then
		verified = true
		print("[PerfectJumpClientQA] COMPLETE")
	end
end

function RuntimeQaController.start()
	if started or not RunService:IsStudio() or not RuntimeQaConfig.EnabledInStudio then
		return
	end
	started = true

	local initialCharacter = player.Character
	player.CharacterAdded:Connect(function(character)
		if character == initialCharacter or verified then
			return
		end
		task.spawn(verifyRespawn, character)
	end)
end

return RuntimeQaController
