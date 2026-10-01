--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GameConfig = require(shared.config.GameConfig)

local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundState = remotes:WaitForChild("RoundState") :: RemoteEvent
local getPlayerState = remotes:WaitForChild("GetPlayerState") :: RemoteFunction

local CameraController = {}

local currentPosition: Vector3? = nil
local targetPosition: Vector3? = nil

local function getRoot(): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function ingestState(payload: any)
	if type(payload) ~= "table" then
		return
	end
	if typeof(payload.CurrentPosition) == "Vector3" then
		currentPosition = payload.CurrentPosition
	end
	if typeof(payload.TargetPosition) == "Vector3" then
		targetPosition = payload.TargetPosition
	end
end

local function refreshInitialState()
	local ok, payload = pcall(function()
		return getPlayerState:InvokeServer()
	end)
	if ok then
		ingestState(payload)
	end
end

function CameraController.start()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = GameConfig.Camera.FieldOfView

	roundState.OnClientEvent:Connect(ingestState)
	player.CharacterAdded:Connect(function()
		task.defer(refreshInitialState)
	end)
	task.defer(refreshInitialState)

	RunService:BindToRenderStep("PerfectJumpCamera", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = GameConfig.Camera.FieldOfView

		local root = getRoot()
		local target = targetPosition
		local current = currentPosition
		if not root or not target or not current then
			return
		end

		local phase = player:GetAttribute("PerfectJumpPhase")
		local avatarPosition = root.Position
		local anchor = if phase == "Airborne" then avatarPosition else current
		local focus = anchor:Lerp(target, GameConfig.Camera.TargetLead) + Vector3.new(0, 2.2, 0)
		local directionDelta = target - anchor
		local horizontal = Vector3.new(directionDelta.X, 0, directionDelta.Z)
		if horizontal.Magnitude < 0.001 then
			horizontal = Vector3.new(0, 0, 1)
		end
		local direction = horizontal.Unit

		local cameraPosition =
			focus - direction * GameConfig.Camera.Distance + Vector3.new(0, GameConfig.Camera.Height, 0)
		local desired = CFrame.lookAt(cameraPosition, focus)

		local alpha = 1 - math.exp(-GameConfig.Camera.Smoothness * math.max(deltaTime, 0))
		camera.CFrame = camera.CFrame:Lerp(desired, alpha)
		camera.Focus = CFrame.new(focus)
	end)
end

return CameraController
