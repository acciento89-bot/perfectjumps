--!strict

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldArtService = {}

local lightingConfigured = false

local COLORS = {
	Foundation = Color3.fromRGB(35, 50, 62),
	Steel = Color3.fromRGB(52, 75, 88),
	SteelLight = Color3.fromRGB(78, 108, 121),
	Amber = Color3.fromRGB(255, 178, 72),
	Cyan = Color3.fromRGB(91, 220, 239),
	Glass = Color3.fromRGB(112, 154, 177),
}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	material: Enum.Material,
	color: Color3,
	transparency: number?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = true
	item.Material = material
	item.Color = color
	item.Transparency = transparency or 0
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function rod(parent: Instance, name: string, fromPosition: Vector3, toPosition: Vector3, thickness: number)
	local delta = toPosition - fromPosition
	if delta.Magnitude < 0.05 then
		return
	end
	part(
		parent,
		name,
		Vector3.new(thickness, thickness, delta.Magnitude),
		CFrame.lookAt((fromPosition + toPosition) / 2, toPosition),
		Enum.Material.Metal,
		COLORS.Steel
	)
end

local function practical(parent: Instance, position: Vector3, color: Color3)
	local post = part(
		parent,
		"PracticalPost",
		Vector3.new(0.26, 2.5, 0.26),
		CFrame.new(position + Vector3.new(0, 1.25, 0)),
		Enum.Material.Metal,
		COLORS.Foundation
	)
	local lamp = part(
		parent,
		"PracticalLamp",
		Vector3.new(0.58, 0.18, 0.58),
		post.CFrame + Vector3.new(0, 1.33, 0),
		Enum.Material.Neon,
		color
	)
	lamp.CastShadow = false

	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 0.85
	light.Range = 9
	light.Shadows = false
	light.Parent = lamp
end

local function tower(parent: Instance, position: Vector3, size: Vector3, index: number)
	local body = part(
		parent,
		"SkylineMass",
		size,
		CFrame.new(position + Vector3.new(0, size.Y / 2, 0)),
		Enum.Material.Concrete,
		Color3.fromRGB(48 + index * 2, 61 + index * 2, 73 + index * 3)
	)

	for row = 1, math.clamp(math.floor(size.Y / 13), 2, 6) do
		local band = part(
			parent,
			"SkylineWindowBand",
			Vector3.new(math.max(3, size.X - 1.6), 0.12, 0.09),
			CFrame.new(position + Vector3.new(0, row * size.Y / 7, -(size.Z / 2 + 0.05))),
			Enum.Material.Neon,
			if row % 2 == 0 then COLORS.Amber else COLORS.Cyan,
			0.34
		)
		band.CastShadow = false
	end

	local roof = part(
		parent,
		"RoofGuide",
		Vector3.new(math.max(2, size.X - 2.4), 0.12, 0.20),
		CFrame.new(position + Vector3.new(0, size.Y + 0.08, 0)),
		Enum.Material.Neon,
		COLORS.Cyan,
		0.30
	)
	roof.CastShadow = false
	body.CastShadow = true
end

function WorldArtService.configureLighting()
	if lightingConfigured then
		return
	end
	lightingConfigured = true

	Lighting.ClockTime = 17.1
	Lighting.Brightness = 2.0
	Lighting.ExposureCompensation = 0.04
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.30
	Lighting.Ambient = Color3.fromRGB(72, 83, 101)
	Lighting.OutdoorAmbient = Color3.fromRGB(110, 120, 136)

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.29
	atmosphere.Haze = 1.65
	atmosphere.Color = Color3.fromRGB(195, 220, 234)
	atmosphere.Decay = Color3.fromRGB(100, 116, 138)
	atmosphere.Glare = 0.10
	atmosphere.Parent = Lighting

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	bloom.Intensity = 0.18
	bloom.Size = 20
	bloom.Threshold = 1.55
	bloom.Parent = Lighting

	local color = Lighting:FindFirstChild("PerfectJumpWorldColor")
	if not color then
		color = Instance.new("ColorCorrectionEffect")
		color.Name = "PerfectJumpWorldColor"
		color.Parent = Lighting
	end
	if color:IsA("ColorCorrectionEffect") then
		color.Brightness = 0.01
		color.Contrast = 0.06
		color.Saturation = -0.04
		color.TintColor = Color3.fromRGB(238, 247, 255)
	end

	local clouds = Workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
	clouds.Cover = 0.27
	clouds.Density = 0.32
	clouds.Color = Color3.fromRGB(233, 239, 244)
	clouds.Parent = Workspace.Terrain
end

function WorldArtService.decorateLane(laneModel: Model, origin: Vector3)
	WorldArtService.configureLighting()

	local art = Instance.new("Folder")
	art.Name = "EnvironmentArt"
	art.Parent = laneModel

	local base = part(
		art,
		"LaunchDeck",
		Vector3.new(28, 1.4, 24),
		CFrame.new(origin - Vector3.new(0, 1.25, 4)),
		Enum.Material.Metal,
		COLORS.Foundation
	)
	base.CanQuery = false

	local inset = part(
		art,
		"LaunchDeckInset",
		Vector3.new(24, 0.15, 20),
		CFrame.new(origin - Vector3.new(0, 0.47, 4)),
		Enum.Material.DiamondPlate,
		COLORS.Steel
	)
	inset.CastShadow = false

	for side in { -1, 1 } do
		local x = origin.X + side * 18
		part(
			art,
			"HighlineMast",
			Vector3.new(1.4, 56, 1.4),
			CFrame.new(x, origin.Y + 25, origin.Z + 24),
			Enum.Material.Metal,
			COLORS.Steel
		)

		for yOffset = 4, 48, 11 do
			part(
				art,
				"MastRib",
				Vector3.new(7, 0.42, 0.58),
				CFrame.new(origin.X + side * 15, origin.Y + yOffset, origin.Z + 24),
				Enum.Material.Metal,
				COLORS.Foundation
			)
		end
	end

	for _, zOffset in { 10, 30, 50, 70 } do
		rod(
			art,
			"SuspensionSpan",
			Vector3.new(origin.X - 18, origin.Y + 16 + zOffset * 0.18, origin.Z + zOffset),
			Vector3.new(origin.X + 18, origin.Y + 20 + zOffset * 0.18, origin.Z + zOffset + 7),
			0.18
		)
	end

	for _, offset in
		{
			Vector3.new(-10, 0, -10),
			Vector3.new(10, 0, -10),
			Vector3.new(-10, 0, 5),
			Vector3.new(10, 0, 5),
		}
	do
		practical(art, origin + offset - Vector3.new(0, 0.5, 0), COLORS.Amber)
	end

	for index = 1, 9 do
		local x = origin.X - 72 + index * 15
		local z = origin.Z + 95 + (index % 3) * 13
		local height = 24 + ((index * 7) % 5) * 10
		tower(
			art,
			Vector3.new(x, origin.Y - 38, z),
			Vector3.new(9 + (index % 3) * 3, height, 10 + ((index + 1) % 3) * 2),
			index
		)
	end

	local cloudGarden = Instance.new("Folder")
	cloudGarden.Name = "CloudGarden"
	cloudGarden.Parent = art
	for index = 1, 8 do
		local cloud = part(
			cloudGarden,
			"CloudWisp",
			Vector3.new(10 + (index % 3) * 4, 2.1 + (index % 2) * 0.6, 6 + (index % 4) * 2),
			CFrame.new(origin + Vector3.new(-42 + index * 11, 16 + (index % 3) * 3, 70 + (index % 2) * 12)),
			Enum.Material.SmoothPlastic,
			Color3.fromRGB(236, 248, 250),
			0.52
		)
		cloud.Shape = Enum.PartType.Ball
		cloud.CastShadow = false
	end

	local gateway = Instance.new("Folder")
	gateway.Name = "HeroGateway"
	gateway.Parent = art
	for _, side in { -1, 1 } do
		part(
			gateway,
			"GatewayPillar",
			Vector3.new(1.4, 12, 1.4),
			CFrame.new(origin + Vector3.new(side * 6.2, 10, 82)),
			Enum.Material.Marble,
			COLORS.SteelLight
		)
	end
	local gatewayTop = part(
		gateway,
		"GatewayCrown",
		Vector3.new(14, 1.2, 1.4),
		CFrame.new(origin + Vector3.new(0, 16, 82)),
		Enum.Material.Marble,
		COLORS.SteelLight
	)
	local gatewayRune = part(
		gateway,
		"GatewayRune",
		Vector3.new(10.5, 0.18, 0.34),
		gatewayTop.CFrame + Vector3.new(0, 0.72, -0.1),
		Enum.Material.Neon,
		COLORS.Amber,
		0.08
	)
	gatewayRune.CastShadow = false

	local sun = part(
		art,
		"SkySunDisc",
		Vector3.new(18, 18, 18),
		CFrame.new(origin + Vector3.new(44, 48, 145)),
		Enum.Material.Neon,
		Color3.fromRGB(255, 194, 121),
		0.08
	)
	sun.Shape = Enum.PartType.Ball
	sun.CastShadow = false

	local crown = part(
		art,
		"PrecisionBeacon",
		Vector3.new(5.5, 0.35, 5.5),
		CFrame.new(origin + Vector3.new(0, 42, 88)),
		Enum.Material.Neon,
		COLORS.Cyan,
		0.12
	)
	crown.CastShadow = false

	local beaconLight = Instance.new("PointLight")
	beaconLight.Color = COLORS.Cyan
	beaconLight.Brightness = 0.75
	beaconLight.Range = 14
	beaconLight.Shadows = false
	beaconLight.Parent = crown
end

return WorldArtService
