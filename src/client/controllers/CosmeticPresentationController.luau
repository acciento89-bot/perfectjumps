--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local CosmeticConfig = require(shared.config.CosmeticConfig)

local CosmeticPresentationController = {}

local trail: Trail? = nil
local attachmentA: Attachment? = nil
local attachmentB: Attachment? = nil

local function rgb(values): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function clearTrail()
	if trail then
		trail:Destroy()
		trail = nil
	end
	if attachmentA then
		attachmentA:Destroy()
		attachmentA = nil
	end
	if attachmentB then
		attachmentB:Destroy()
		attachmentB = nil
	end
end

local function applyTrail()
	clearTrail()

	local trailId = player:GetAttribute("PerfectJumpTrail")
	if type(trailId) ~= "string" or trailId == "none" then
		return
	end
	local definition = CosmeticConfig.Categories.Trails.Items[trailId]
	if not definition or not definition.RGB then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end

	attachmentA = Instance.new("Attachment")
	attachmentA.Name = "PerfectJumpTrailA"
	attachmentA.Position = Vector3.new(-0.55, -1.2, 0.2)
	attachmentA.Parent = root

	attachmentB = Instance.new("Attachment")
	attachmentB.Name = "PerfectJumpTrailB"
	attachmentB.Position = Vector3.new(0.55, -1.2, 0.2)
	attachmentB.Parent = root

	trail = Instance.new("Trail")
	trail.Name = "PerfectJumpTrail"
	trail.Attachment0 = attachmentA
	trail.Attachment1 = attachmentB
	trail.Color = ColorSequence.new(rgb(definition.RGB), Color3.fromRGB(235, 247, 255))
	trail.Lifetime = 0.28
	trail:SetAttribute("BaseLifetime", 0.28)
	trail.MinLength = 0.08
	trail.LightEmission = 0.35
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.08),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Parent = root
end

local function currentLane(): Model?
	local world = Workspace:FindFirstChild("PerfectJumpWorld")
	if not world then
		return nil
	end
	local lane = world:FindFirstChild(("Lane_%d"):format(player.UserId))
	if lane and lane:IsA("Model") then
		return lane
	end
	return nil
end

local function applyPlatformTheme()
	local themeId = player:GetAttribute("PerfectJumpPlatformTheme")
	if type(themeId) ~= "string" then
		themeId = CosmeticConfig.Categories.PlatformThemes.Default
	end
	local theme = CosmeticConfig.Categories.PlatformThemes.Items[themeId]
	if not theme then
		return
	end

	local lane = currentLane()
	if not lane then
		return
	end
	for _, descendant in lane:GetDescendants() do
		if descendant:IsA("BasePart") then
			if descendant.Name == "Collision" or descendant.Name == "UnderFrame" then
				descendant.Color = rgb(theme.BaseRGB)
			elseif descendant.Name == "SweetZone" or descendant.Name == "EdgeTrim" then
				descendant.Color = rgb(theme.AccentRGB)
			end
		end
	end
end

local function applyEnvironmentTheme()
	local themeId = player:GetAttribute("PerfectJumpEnvironmentTheme")
	if type(themeId) ~= "string" then
		themeId = CosmeticConfig.Categories.EnvironmentThemes.Default
	end

	local correction = Lighting:FindFirstChild("PerfectJumpLocalColor")
	if not correction then
		correction = Instance.new("ColorCorrectionEffect")
		correction.Name = "PerfectJumpLocalColor"
		correction.Parent = Lighting
	end
	if not correction:IsA("ColorCorrectionEffect") then
		return
	end

	if themeId == "dusk" then
		correction.TintColor = Color3.fromRGB(255, 220, 208)
		correction.Contrast = 0.08
		correction.Saturation = -0.02
	elseif themeId == "storm" then
		correction.TintColor = Color3.fromRGB(192, 218, 235)
		correction.Contrast = 0.12
		correction.Saturation = -0.12
	else
		correction.TintColor = Color3.fromRGB(238, 247, 255)
		correction.Contrast = 0.05
		correction.Saturation = -0.04
	end
end

function CosmeticPresentationController.start()
	player:GetAttributeChangedSignal("PerfectJumpTrail"):Connect(applyTrail)
	player:GetAttributeChangedSignal("PerfectJumpPlatformTheme"):Connect(applyPlatformTheme)
	player:GetAttributeChangedSignal("PerfectJumpEnvironmentTheme"):Connect(applyEnvironmentTheme)

	player.CharacterAdded:Connect(function()
		task.delay(0.2, applyTrail)
	end)

	Workspace.DescendantAdded:Connect(function(descendant)
		if not descendant:IsA("BasePart") then
			return
		end
		local lane = currentLane()
		if lane and descendant:IsDescendantOf(lane) then
			task.defer(applyPlatformTheme)
		end
	end)

	task.defer(applyTrail)
	task.defer(applyPlatformTheme)
	task.defer(applyEnvironmentTheme)
end

return CosmeticPresentationController
