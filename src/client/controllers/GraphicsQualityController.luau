--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GraphicsQualityRules = require(shared.game.GraphicsQualityRules)

local GraphicsQualityController = {}

local gameSettings = UserSettings():GetService("UserGameSettings") :: any

local function savedQualityValue(): number
	local quality = gameSettings.SavedQualityLevel
	local value = (quality :: any).Value
	return if type(value) == "number" then value else 0
end

local function isEnvironmentLight(instance: Instance): boolean
	local current: Instance? = instance
	while current do
		if current.Name == "EnvironmentArt" then
			return true
		end
		current = current.Parent
	end
	return false
end

local function applyInstance(instance: Instance, profile)
	if instance:IsA("BloomEffect") then
		instance.Enabled = profile.BloomEnabled
	elseif instance:IsA("PointLight") and isEnvironmentLight(instance) then
		instance.Enabled = profile.DecorativePointLightsEnabled
	elseif instance:IsA("Trail") and instance.Name == "PerfectJumpTrail" then
		local baseLifetime = tonumber(instance:GetAttribute("BaseLifetime")) or 0.28
		instance.Lifetime = baseLifetime * profile.TrailLifetimeScale
	end
end

local function apply()
	local profile = GraphicsQualityRules.profile(savedQualityValue())
	player:SetAttribute("PerfectJumpLowGraphics", profile.Low)

	for _, instance in Lighting:GetDescendants() do
		applyInstance(instance, profile)
	end
	for _, instance in Workspace:GetDescendants() do
		applyInstance(instance, profile)
	end
end

function GraphicsQualityController.start()
	apply()
	gameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(apply)
	Lighting.DescendantAdded:Connect(function(instance)
		task.defer(applyInstance, instance, GraphicsQualityRules.profile(savedQualityValue()))
	end)
	Workspace.DescendantAdded:Connect(function(instance)
		task.defer(applyInstance, instance, GraphicsQualityRules.profile(savedQualityValue()))
	end)
end

return GraphicsQualityController
