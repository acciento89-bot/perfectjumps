--!strict

local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GameConfig = require(shared.config.GameConfig)
local WorldArtService = require(script.Parent.WorldArtService)
local ReachabilityRules = require(shared.game.ReachabilityRules)

local WorldService = {}

export type Lane = {
	Model: Model,
	Origin: Vector3,
	Spawn: SpawnLocation,
	CurrentPlatform: Model,
	CurrentCollision: BasePart,
	TargetPlatform: Model,
	TargetCollision: BasePart,
	CurrentId: number,
	TargetId: number,
	History: { Model },
}

local worldRoot: Folder? = nil

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	material: Enum.Material,
	color: Color3,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanQuery = true
	part.CanTouch = true
	part.Material = material
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function platformWidth(platformId: number): number
	return ReachabilityRules.platformWidth(platformId)
end

local function nextCenter(currentCenter: Vector3, nextId: number): Vector3
	local lateral, vertical, gap = ReachabilityRules.generatorOffset(nextId)
	local width = platformWidth(nextId)
	local landingRadius = math.max(0.8, width / 2 - GameConfig.Platform.EdgeSafetyMargin)
	local horizontalDistance = math.sqrt(lateral * lateral + gap * gap)
	assert(
		ReachabilityRules.isReachable(horizontalDistance, vertical, landingRadius),
		("generated platform %d is outside the configured jump envelope"):format(nextId)
	)
	return currentCenter + Vector3.new(lateral, vertical, gap)
end

local function createPlatform(parent: Instance, platformId: number, center: Vector3): (Model, BasePart)
	local width = platformWidth(platformId)
	local model = Instance.new("Model")
	model.Name = ("Platform_%03d"):format(platformId)
	model:SetAttribute("PlatformId", platformId)
	model:SetAttribute("Width", width)
	model.Parent = parent

	local collision = makePart(
		model,
		"Collision",
		Vector3.new(width, GameConfig.Platform.Height, GameConfig.Platform.Depth),
		CFrame.new(center),
		Enum.Material.Metal,
		Color3.fromRGB(54, 61, 72),
		true
	)
	model.PrimaryPart = collision

	local inset = makePart(
		model,
		"LandingDeck",
		Vector3.new(math.max(1, width - 0.5), 0.16, math.max(1, GameConfig.Platform.Depth - 0.5)),
		CFrame.new(center + Vector3.new(0, GameConfig.Platform.Height / 2 + 0.1, 0)),
		Enum.Material.SmoothPlastic,
		Color3.fromRGB(79, 88, 102),
		false
	)
	inset.CanTouch = false

	local goodDiameter = math.min(width - 0.8, GameConfig.Landing.GoodRadius * 2)
	local perfectDiameter = math.min(goodDiameter - 0.4, GameConfig.Landing.PerfectRadius * 2)
	model:SetAttribute("GoodZoneDiameter", goodDiameter)
	model:SetAttribute("PerfectZoneDiameter", perfectDiameter)

	local goodZone = makePart(
		model,
		"GoodZone",
		Vector3.new(math.max(1.2, goodDiameter), 0.06, math.max(1.2, goodDiameter)),
		CFrame.new(center + Vector3.new(0, GameConfig.Platform.Height / 2 + 0.20, 0)),
		Enum.Material.SmoothPlastic,
		Color3.fromRGB(72, 118, 133),
		false
	)
	goodZone.Transparency = 0.18
	goodZone.CanTouch = false

	local perfectCore = makePart(
		model,
		"PerfectCore",
		Vector3.new(math.max(1.0, perfectDiameter), 0.08, math.max(1.0, perfectDiameter)),
		CFrame.new(center + Vector3.new(0, GameConfig.Platform.Height / 2 + 0.25, 0)),
		Enum.Material.Neon,
		Color3.fromRGB(255, 184, 76),
		false
	)
	perfectCore.Transparency = 0.06
	perfectCore.CanTouch = false

	local landingRingRadius = math.max(0.75, perfectDiameter / 2 + 0.26)
	for _, definition in
		{
			{ Vector3.new(math.max(1.1, perfectDiameter), 0.06, 0.10), Vector3.new(0, 0, -landingRingRadius) },
			{ Vector3.new(math.max(1.1, perfectDiameter), 0.06, 0.10), Vector3.new(0, 0, landingRingRadius) },
			{ Vector3.new(0.10, 0.06, math.max(1.1, perfectDiameter)), Vector3.new(-landingRingRadius, 0, 0) },
			{ Vector3.new(0.10, 0.06, math.max(1.1, perfectDiameter)), Vector3.new(landingRingRadius, 0, 0) },
		}
	do
		local ring = makePart(
			model,
			"LandingRing",
			definition[1],
			CFrame.new(center + Vector3.new(0, GameConfig.Platform.Height / 2 + 0.285, 0) + definition[2]),
			Enum.Material.Neon,
			Color3.fromRGB(255, 205, 107),
			false
		)
		ring.Transparency = 0.18
		ring.CanTouch = false
		ring.CanQuery = false
	end

	local bracketOffset = math.max(0.65, goodDiameter / 2 - 0.24)
	for _, direction in
		{
			Vector3.new(-bracketOffset, 0, -bracketOffset),
			Vector3.new(bracketOffset, 0, -bracketOffset),
			Vector3.new(-bracketOffset, 0, bracketOffset),
			Vector3.new(bracketOffset, 0, bracketOffset),
		}
	do
		local bracket = makePart(
			model,
			"TargetBracket",
			Vector3.new(0.34, 0.09, 0.34),
			CFrame.new(center + Vector3.new(direction.X, GameConfig.Platform.Height / 2 + 0.27, direction.Z)),
			Enum.Material.Neon,
			Color3.fromRGB(121, 226, 239),
			false
		)
		bracket.Transparency = 0.10
		bracket.CanTouch = false
	end

	local underFrame = makePart(
		model,
		"UnderFrame",
		Vector3.new(math.max(1, width - 1.1), 0.36, math.max(1, GameConfig.Platform.Depth - 1.1)),
		CFrame.new(center - Vector3.new(0, GameConfig.Platform.Height / 2 + 0.24, 0)),
		Enum.Material.Metal,
		Color3.fromRGB(29, 34, 42),
		false
	)
	underFrame.CanTouch = false

	local platformFin = makePart(
		model,
		"PlatformFin",
		Vector3.new(math.max(0.4, width * 0.12), 1.6, math.max(1.4, GameConfig.Platform.Depth - 1.8)),
		CFrame.new(center + Vector3.new(0, -(GameConfig.Platform.Height / 2 + 1.0), 0)),
		Enum.Material.Metal,
		Color3.fromRGB(33, 43, 53),
		false
	)
	platformFin.Transparency = 0.04
	platformFin.CanTouch = false
	platformFin.CanQuery = false

	for _, xSign in { -1, 1 } do
		local edge = makePart(
			model,
			"EdgeTrim",
			Vector3.new(0.16, 0.3, GameConfig.Platform.Depth - 0.4),
			CFrame.new(center + Vector3.new(xSign * (width / 2 - 0.08), GameConfig.Platform.Height / 2 + 0.03, 0)),
			Enum.Material.Metal,
			Color3.fromRGB(222, 135, 48),
			false
		)
		edge.CanTouch = false
	end
	for _, zSign in { -1, 1 } do
		local edge = makePart(
			model,
			"EdgeTrim",
			Vector3.new(math.max(1, width - 0.4), 0.3, 0.16),
			CFrame.new(
				center
					+ Vector3.new(
						0,
						GameConfig.Platform.Height / 2 + 0.03,
						zSign * (GameConfig.Platform.Depth / 2 - 0.08)
					)
			),
			Enum.Material.Metal,
			Color3.fromRGB(222, 135, 48),
			false
		)
		edge.CanTouch = false
	end

	return model, collision
end

function WorldService.start()
	Workspace.Gravity = 196.2
	local existing = Workspace:FindFirstChild("PerfectJumpWorld")
	if existing then
		existing:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "PerfectJumpWorld"
	root.Parent = Workspace
	worldRoot = root
end

function WorldService.createLane(player: Player, laneIndex: number): Lane
	assert(worldRoot ~= nil, "WorldService.start must run before createLane")

	local laneModel = Instance.new("Model")
	laneModel.Name = ("Lane_%d"):format(player.UserId)
	laneModel:SetAttribute("OwnerUserId", player.UserId)
	laneModel.Parent = worldRoot

	local origin = Vector3.new((laneIndex - 1) * GameConfig.Generation.LaneSpacing, 8, 0)
	local platforms = Instance.new("Folder")
	platforms.Name = "Platforms"
	platforms.Parent = laneModel

	local currentPlatform, currentCollision = createPlatform(platforms, 0, origin)
	local targetCenter = nextCenter(origin, 1)
	local targetPlatform, targetCollision = createPlatform(platforms, 1, targetCenter)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SafeSpawn"
	spawn.Size = Vector3.new(4, 0.6, 4)
	spawn.CFrame = CFrame.new(origin + Vector3.new(0, 2.8, 0))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.Transparency = 1
	spawn.Neutral = true
	spawn.Enabled = true
	spawn.Parent = laneModel

	WorldArtService.decorateLane(laneModel, origin)

	return {
		Model = laneModel,
		Origin = origin,
		Spawn = spawn,
		CurrentPlatform = currentPlatform,
		CurrentCollision = currentCollision,
		TargetPlatform = targetPlatform,
		TargetCollision = targetCollision,
		CurrentId = 0,
		TargetId = 1,
		History = { currentPlatform, targetPlatform },
	}
end

function WorldService.advanceLane(lane: Lane)
	lane.CurrentPlatform = lane.TargetPlatform
	lane.CurrentCollision = lane.TargetCollision
	lane.CurrentId = lane.TargetId
	lane.TargetId += 1

	local currentCenter = lane.CurrentCollision.Position
	local nextPlatform, nextCollision =
		createPlatform(lane.CurrentPlatform.Parent, lane.TargetId, nextCenter(currentCenter, lane.TargetId))
	lane.TargetPlatform = nextPlatform
	lane.TargetCollision = nextCollision
	table.insert(lane.History, nextPlatform)

	while #lane.History > GameConfig.Generation.VisiblePlatformHistory do
		local old = table.remove(lane.History, 1)
		if old ~= lane.CurrentPlatform and old ~= lane.TargetPlatform then
			old:Destroy()
		end
	end
end

function WorldService.destroyLane(lane: Lane)
	if lane.Model.Parent then
		lane.Model:Destroy()
	end
end

return WorldService
