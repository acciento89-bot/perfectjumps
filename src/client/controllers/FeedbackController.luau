--!strict

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundState = remotes:WaitForChild("RoundState") :: RemoteEvent

local FeedbackController = {}

local SOUND_ID = "rbxasset://sounds/electronicpingshort.wav"
local lastCueAt: { [string]: number } = {}
local transientSounds = 0
local MAX_TRANSIENT = 4

local CUES = {
	Perfect = { Speed = 1.35, Volume = 0.24, MinInterval = 0.08 },
	Good = { Speed = 1.08, Volume = 0.20, MinInterval = 0.08 },
	Safe = { Speed = 0.88, Volume = 0.17, MinInterval = 0.08 },
	Failure = { Speed = 0.58, Volume = 0.26, MinInterval = 0.45 },
	Reward = { Speed = 1.52, Volume = 0.23, MinInterval = 0.32 },
}

local function audioEnabled(): boolean
	return player:GetAttribute("PerfectJumpAudioEnabled") ~= false
end

local function reducedMotion(): boolean
	return player:GetAttribute("PerfectJumpReducedMotion") == true
end

local function playCue(name: string)
	if not audioEnabled() or transientSounds >= MAX_TRANSIENT then
		return
	end

	local definition = CUES[name]
	if not definition then
		return
	end

	local now = os.clock()
	local previous = lastCueAt[name]
	if previous and now - previous < definition.MinInterval then
		return
	end
	lastCueAt[name] = now

	local sound = Instance.new("Sound")
	sound.Name = "PerfectJump_" .. name
	sound.SoundId = SOUND_ID
	sound.Volume = math.min(0.28, definition.Volume)
	sound.PlaybackSpeed = definition.Speed
	sound.Parent = SoundService
	transientSounds += 1
	sound.Ended:Connect(function()
		transientSounds = math.max(0, transientSounds - 1)
	end)
	Debris:AddItem(sound, 3)
	sound:Play()
end

local function rootPart(): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function landingRing(color: Color3, diameter: number)
	if reducedMotion() then
		return
	end
	local root = rootPart()
	if not root then
		return
	end

	local ring = Instance.new("Part")
	ring.Name = "PerfectJumpLandingRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.06, 2.1, 2.1)
	ring.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanTouch = false
	ring.CanQuery = false
	ring.CastShadow = false
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.18
	ring.Parent = Workspace

	TweenService:Create(ring, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.03, diameter, diameter),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ring, 0.5)
end

local function sparkBurst(color: Color3)
	if reducedMotion() then
		return
	end
	local root = rootPart()
	if not root then
		return
	end

	for index = 1, 7 do
		local angle = index / 7 * math.pi * 2
		local spark = Instance.new("Part")
		spark.Name = "PerfectJumpSpark"
		spark.Size = Vector3.new(0.10, 0.36, 0.10)
		spark.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.3, 0))
		spark.Anchored = false
		spark.CanCollide = false
		spark.CanTouch = false
		spark.CanQuery = false
		spark.CastShadow = false
		spark.Material = Enum.Material.Neon
		spark.Color = color
		spark.AssemblyLinearVelocity =
			Vector3.new(math.cos(angle) * 4.2, 5.2 + (index % 3), math.sin(angle) * 4.2)
		spark.Parent = Workspace
		Debris:AddItem(spark, 0.7)
	end
end

local function failureKick()
	if reducedMotion() then
		return
	end
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local original = camera.FieldOfView
	TweenService:Create(camera, TweenInfo.new(0.10, Enum.EasingStyle.Quad), {
		FieldOfView = original + 3,
	}):Play()
	task.delay(0.12, function()
		if camera.Parent then
			TweenService:Create(camera, TweenInfo.new(0.24, Enum.EasingStyle.Quint), {
				FieldOfView = original,
			}):Play()
		end
	end)
end

local function onRoundState(payload: any)
	if type(payload) ~= "table" then
		return
	end

	if type(payload.Grade) == "string" then
		if payload.Grade == "Perfect" then
			playCue("Perfect")
			landingRing(Color3.fromRGB(255, 194, 85), 7.2)
			sparkBurst(Color3.fromRGB(255, 220, 130))
		elseif payload.Grade == "Good" then
			playCue("Good")
			landingRing(Color3.fromRGB(91, 220, 239), 5.8)
		elseif payload.Grade == "Safe" then
			playCue("Safe")
			landingRing(Color3.fromRGB(211, 222, 235), 4.8)
		end

		local reward = payload.Reward
		if type(reward) == "table"
			and (reward.NewPB == true
				or (tonumber(reward.AchievementCoins) or 0) > 0
				or (tonumber(reward.ChallengeCoins) or 0) > 0)
		then
			task.delay(0.12, function()
				playCue("Reward")
			end)
		end
	elseif payload.Reason then
		playCue("Failure")
		failureKick()
	end
end

function FeedbackController.start()
	roundState.OnClientEvent:Connect(onRoundState)
end

return FeedbackController
