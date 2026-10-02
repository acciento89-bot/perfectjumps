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
local snappedCharacter: Model? = nil
local lastTargetId: number? = nil

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
	if type(payload.TargetPlatformId) == "number" then
		local targetId = math.floor(payload.TargetPlatformId)
		if lastTargetId and math.abs(targetId - lastTargetId) >= 3 then
			snappedCharacter = nil
		end
		lastTargetId = targetId
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

local function desiredCFrame(camera: Camera, root: BasePart, current: Vector3, target: Vector3): (CFrame, Vector3)
	local compact = camera.ViewportSize.X <= 760
	local phase = player:GetAttribute("PerfectJumpPhase")
	local avatarPosition = root.Position
	local anchor = if phase == "Airborne" then avatarPosition else current
	local lead = if compact then 0.53 else GameConfig.Camera.TargetLead
	local focus = anchor:Lerp(target, lead) + Vector3.new(0, if compact then 2.0 else 2.25, 0)

	local directionDelta = target - anchor
	local horizontal = Vector3.new(directionDelta.X, 0, directionDelta.Z)
	if horizontal.Magnitude < 0.001 then
		horizontal = root.CFrame.LookVector
		horizontal = Vector3.new(horizontal.X, 0, horizontal.Z)
	end
	if horizontal.Magnitude < 0.001 then
		horizontal = Vector3.new(0, 0, 1)
	end
	local direction = horizontal.Unit

	local distance = if compact then 15.4 else GameConfig.Camera.Distance
	local height = if compact then 7.7 else GameConfig.Camera.Height
	local cameraPosition = focus - direction * distance + Vector3.new(0, height, 0)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = if player.Character then { player.Character } else {}
	params.IgnoreWater = true
	local ray = cameraPosition - focus
	local hit = Workspace:Raycast(focus, ray, params)
	if hit then
		cameraPosition = focus + ray.Unit * math.max(5.8, hit.Distance - 0.7)
	end

	camera.FieldOfView = if compact then 71 else GameConfig.Camera.FieldOfView
	return CFrame.lookAt(cameraPosition, focus, Vector3.yAxis), focus
end

local function snapIfReady()
	local camera = Workspace.CurrentCamera
	local character = player.Character
	local root = getRoot()
	local current = currentPosition
	local target = targetPosition
	if not camera or not character or not root or not current or not target then
		return
	end
	local desired, focus = desiredCFrame(camera, root, current, target)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = desired
	camera.Focus = CFrame.new(focus)
	snappedCharacter = character
end

function CameraController.start()
	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = GameConfig.Camera.FieldOfView

	roundState.OnClientEvent:Connect(function(payload)
		ingestState(payload)
		if snappedCharacter == nil then
			task.defer(snapIfReady)
		end
	end)

	player.CharacterAdded:Connect(function(character)
		snappedCharacter = nil
		currentPosition = nil
		targetPosition = nil
		task.defer(refreshInitialState)
		task.defer(function()
			if player.Character == character then
				snapIfReady()
			end
		end)
	end)
	player.CharacterRemoving:Connect(function(character)
		if snappedCharacter == character then
			snappedCharacter = nil
		end
	end)
	task.defer(refreshInitialState)

	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		snappedCharacter = nil
		task.defer(snapIfReady)
	end)

	RunService:BindToRenderStep("PerfectJumpCamera", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
		local activeCamera = Workspace.CurrentCamera
		local character = player.Character
		local root = getRoot()
		local target = targetPosition
		local current = currentPosition
		if not activeCamera or not character or not root or not target or not current then
			return
		end

		local desired, focus = desiredCFrame(activeCamera, root, current, target)
		activeCamera.CameraType = Enum.CameraType.Scriptable

		if snappedCharacter ~= character then
			activeCamera.CFrame = desired
			activeCamera.Focus = CFrame.new(focus)
			snappedCharacter = character
			return
		end

		local alpha = 1 - math.exp(-GameConfig.Camera.Smoothness * math.max(deltaTime, 0))
		activeCamera.CFrame = activeCamera.CFrame:Lerp(desired, alpha)
		activeCamera.Focus = CFrame.new(focus)
	end)
end

return CameraController
