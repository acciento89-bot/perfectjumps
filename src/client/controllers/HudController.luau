--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GameConfig = require(shared.config.GameConfig)
local MonetizationConfig = require(shared.config.MonetizationConfig)
local ViewportRules = require(shared.game.ViewportRules)

local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundAction = remotes:WaitForChild("RoundAction") :: RemoteEvent
local roundState = remotes:WaitForChild("RoundState") :: RemoteEvent

local HudController = {}

local COLORS = {
	Foundation = Color3.fromRGB(18, 23, 31),
	Panel = Color3.fromRGB(30, 38, 50),
	Text = Color3.fromRGB(245, 248, 252),
	Muted = Color3.fromRGB(166, 178, 194),
	Amber = Color3.fromRGB(255, 178, 72),
	Cyan = Color3.fromRGB(91, 220, 239),
	Fail = Color3.fromRGB(255, 100, 112),
}

local chargeStartedAt: number? = nil
local scale: UIScale
local stats: Frame
local scoreLabel: TextLabel
local comboLabel: TextLabel
local bestLabel: TextLabel
local coinsLabel: TextLabel
local platformLabel: TextLabel
local phaseLabel: TextLabel
local tutorial: Frame
local chargePanel: Frame
local chargeFill: Frame
local gradeLabel: TextLabel
local resultPanel: Frame
local resultScore: TextLabel
local reviveButton: TextButton
local shopButton: TextButton
local logo: Frame
local comboProgress: Frame
local comboProgressFill: Frame
local comboProgressText: TextLabel
local quickRail: Frame

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function stroke(parent: Instance, color: Color3, transparency: number, thickness: number?)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Transparency = transparency
	item.Thickness = thickness or 1
	item.Parent = parent
end

local function makeLabel(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	textSize: number,
	color: Color3,
	font: Enum.Font?
): TextLabel
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Size = size
	item.Position = position
	item.BackgroundTransparency = 1
	item.Font = font or Enum.Font.GothamMedium
	item.Text = text
	item.TextSize = textSize
	item.TextColor3 = color
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function makeButton(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	background: Color3
): TextButton
	local item = Instance.new("TextButton")
	item.Name = name
	item.Size = size
	item.Position = position
	item.BackgroundColor3 = background
	item.BorderSizePixel = 0
	item.Font = Enum.Font.GothamBold
	item.Text = text
	item.TextSize = 14
	item.TextColor3 = COLORS.Foundation
	item.AutoButtonColor = true
	item.Selectable = true
	item.Parent = parent
	corner(item, 12)
	return item
end

local function updateResponsive()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local width = camera.ViewportSize.X
	local viewportClass = ViewportRules.classify(width)
	scale.Scale = ViewportRules.uiScale(width)

	if viewportClass == "compact" then
		logo.Visible = false
		comboProgress.Visible = false
		quickRail.Visible = false
		shopButton.Visible = true
		stats.Position = UDim2.fromOffset(12, 12)
		stats.Size = UDim2.fromOffset(290, 84)
		shopButton.Position = UDim2.new(1, -112, 0, 112)
		chargePanel.Size = UDim2.new(1, -36, 0, 78)
		tutorial.Size = UDim2.new(1, -30, 0, 90)
	elseif viewportClass == "tablet" then
		logo.Visible = true
		comboProgress.Visible = true
		quickRail.Visible = true
		shopButton.Visible = false
		logo.Position = UDim2.fromOffset(16, 10)
		stats.Position = UDim2.fromOffset(16, 92)
		stats.Size = UDim2.fromOffset(390, 84)
		shopButton.Position = UDim2.new(1, -124, 0, 18)
		chargePanel.Size = UDim2.fromOffset(460, 78)
		tutorial.Size = UDim2.fromOffset(430, 90)
	else
		logo.Visible = true
		comboProgress.Visible = true
		quickRail.Visible = true
		shopButton.Visible = false
		logo.Position = UDim2.fromOffset(20, 12)
		stats.Position = UDim2.fromOffset(20, 92)
		stats.Position = UDim2.fromOffset(20, 92)
		stats.Size = UDim2.fromOffset(440, 84)
		shopButton.Position = UDim2.new(1, -132, 0, 22)
		chargePanel.Size = UDim2.fromOffset(460, 78)
		tutorial.Size = UDim2.fromOffset(440, 90)
	end
end

local function refreshHud()
	local score = tonumber(player:GetAttribute("PerfectJumpScore")) or 0
	local combo = tonumber(player:GetAttribute("PerfectJumpCombo")) or 0
	local best = tonumber(player:GetAttribute("PerfectJumpBestScore")) or 0
	local highest = tonumber(player:GetAttribute("PerfectJumpHighestPlatform")) or 0
	local currentPlatform = tonumber(player:GetAttribute("PerfectJumpCurrentPlatform")) or 0
	local coins = tonumber(player:GetAttribute("PerfectJumpCoins")) or 0
	local revives = tonumber(player:GetAttribute("PerfectJumpRevives")) or 0
	local phaseValue = player:GetAttribute("PerfectJumpPhase")
	local phase = if type(phaseValue) == "string" then phaseValue else "Ready"
	local assisted = player:GetAttribute("PerfectJumpAssisted") == true

	scoreLabel.Text = ("SCORE  %d"):format(score)
	comboLabel.Text = ("COMBO  %d"):format(combo)
	comboProgressText.Text = ("COMBO %d • NEXT BOOST 10"):format(combo)
	comboProgressFill.Size = UDim2.fromScale(math.clamp(combo / 10, 0, 1), 1)
	bestLabel.Text = ("PB  %d"):format(best)
	coinsLabel.Text = ("◈ %d"):format(coins)
	platformLabel.Text = ("PLATFORM  %d   •   HIGH  %d"):format(currentPlatform, highest)
	phaseLabel.Text = if assisted then string.upper(phase) .. "  •  ASSISTED" else string.upper(phase)

	resultPanel.Visible = phase == "GameOver"
	chargePanel.Visible = phase ~= "GameOver"
	tutorial.Visible = player:GetAttribute("PerfectJumpTutorialComplete") ~= true and phase ~= "GameOver"

	if resultPanel.Visible then
		resultScore.Text = ("SCORE  %d   •   PB  %d"):format(score, best)
		if revives > 0 then
			reviveButton.Text = ("REVIVE  (%d)"):format(revives)
		elseif MonetizationConfig.DeveloperProducts.Revive.ProductId > 0 then
			reviveButton.Text = ("GET REVIVE  %d R$"):format(MonetizationConfig.DeveloperProducts.Revive.Robux)
		else
			reviveButton.Text = "REVIVE UNAVAILABLE"
		end
	end

	if phase == "Charging" then
		if chargeStartedAt == nil then
			chargeStartedAt = os.clock()
		end
	else
		chargeStartedAt = nil
		if phase == "Ready" or phase == "GameOver" then
			chargeFill.Size = UDim2.fromScale(0, 1)
		end
	end
end

local function buildGui()
	local existing = playerGui:FindFirstChild("PerfectJumpHUD")
	if existing then
		existing:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "PerfectJumpHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 20
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	scale = Instance.new("UIScale")
	scale.Name = "ResponsiveScale"
	scale.Parent = gui

	logo = Instance.new("Frame")
	logo.Name = "PerfectJumpLogo"
	logo.Position = UDim2.fromOffset(20, 12)
	logo.Size = UDim2.fromOffset(190, 72)
	logo.BackgroundTransparency = 1
	logo.Parent = gui

	local perfectWord = makeLabel(
		logo,
		"PerfectWord",
		"PERFECT",
		UDim2.fromOffset(150, 32),
		UDim2.fromOffset(0, 0),
		27,
		COLORS.Cyan,
		Enum.Font.GothamBlack
	)
	perfectWord.TextStrokeColor3 = Color3.fromRGB(26, 48, 62)
	perfectWord.TextStrokeTransparency = 0.36

	local jumpWord = makeLabel(
		logo,
		"JumpWord",
		"JUMP",
		UDim2.fromOffset(136, 34),
		UDim2.fromOffset(18, 27),
		30,
		COLORS.Amber,
		Enum.Font.GothamBlack
	)
	jumpWord.TextStrokeColor3 = Color3.fromRGB(55, 44, 35)
	jumpWord.TextStrokeTransparency = 0.34

	local logoTag = makeLabel(
		logo,
		"Tagline",
		"CHARGE • RELEASE • LAND PERFECT",
		UDim2.fromOffset(188, 12),
		UDim2.fromOffset(1, 60),
		8,
		COLORS.Muted,
		Enum.Font.GothamBold
	)
	logoTag.TextXAlignment = Enum.TextXAlignment.Left

	comboProgress = Instance.new("Frame")
	comboProgress.Name = "ComboProgress"
	comboProgress.AnchorPoint = Vector2.new(0.5, 0)
	comboProgress.Position = UDim2.new(0.5, 0, 0, 14)
	comboProgress.Size = UDim2.fromOffset(290, 52)
	comboProgress.BackgroundColor3 = COLORS.Foundation
	comboProgress.BackgroundTransparency = 0.03
	comboProgress.BorderSizePixel = 0
	comboProgress.Parent = gui
	corner(comboProgress, 16)
	stroke(comboProgress, COLORS.Cyan, 0.42, 1.3)

	comboProgressText = makeLabel(
		comboProgress,
		"Text",
		"COMBO 0 • NEXT BOOST 10",
		UDim2.new(1, -20, 0, 24),
		UDim2.fromOffset(10, 4),
		11,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	comboProgressText.TextXAlignment = Enum.TextXAlignment.Center

	local comboTrack = Instance.new("Frame")
	comboTrack.Position = UDim2.fromOffset(12, 34)
	comboTrack.Size = UDim2.new(1, -24, 0, 10)
	comboTrack.BackgroundColor3 = Color3.fromRGB(22, 33, 43)
	comboTrack.BorderSizePixel = 0
	comboTrack.ClipsDescendants = true
	comboTrack.Parent = comboProgress
	corner(comboTrack, 99)

	comboProgressFill = Instance.new("Frame")
	comboProgressFill.Name = "Fill"
	comboProgressFill.Size = UDim2.fromScale(0, 1)
	comboProgressFill.BackgroundColor3 = COLORS.Amber
	comboProgressFill.BorderSizePixel = 0
	comboProgressFill.Parent = comboTrack
	corner(comboProgressFill, 99)

	stats = Instance.new("Frame")
	stats.Name = "Stats"
	stats.Size = UDim2.fromOffset(440, 84)
	stats.BackgroundColor3 = COLORS.Foundation
	stats.BackgroundTransparency = 0.04
	stats.BorderSizePixel = 0
	stats.Parent = gui
	corner(stats, 16)
	stroke(stats, COLORS.Cyan, 0.64)

	scoreLabel = makeLabel(
		stats,
		"Score",
		"SCORE  0",
		UDim2.fromOffset(128, 27),
		UDim2.fromOffset(14, 8),
		15,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	comboLabel = makeLabel(
		stats,
		"Combo",
		"COMBO  0",
		UDim2.fromOffset(128, 27),
		UDim2.fromOffset(146, 8),
		15,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	bestLabel = makeLabel(
		stats,
		"Best",
		"PB  0",
		UDim2.fromOffset(92, 27),
		UDim2.fromOffset(278, 8),
		15,
		COLORS.Amber,
		Enum.Font.GothamBold
	)
	coinsLabel = makeLabel(
		stats,
		"Coins",
		"◈ 0",
		UDim2.fromOffset(72, 27),
		UDim2.new(1, -82, 0, 8),
		14,
		COLORS.Amber,
		Enum.Font.GothamBold
	)
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
	platformLabel = makeLabel(
		stats,
		"Platform",
		"PLATFORM  0",
		UDim2.fromOffset(230, 24),
		UDim2.fromOffset(14, 48),
		12,
		COLORS.Muted,
		Enum.Font.GothamBold
	)
	phaseLabel = makeLabel(
		stats,
		"Phase",
		"READY",
		UDim2.new(1, -258, 0, 24),
		UDim2.fromOffset(244, 48),
		12,
		COLORS.Cyan,
		Enum.Font.GothamBold
	)
	phaseLabel.TextXAlignment = Enum.TextXAlignment.Right

	shopButton =
		makeButton(gui, "ShopButton", "SUPPLY", UDim2.fromOffset(110, 46), UDim2.new(1, -132, 0, 22), COLORS.Cyan)
	shopButton.Activated:Connect(function()
		player:SetAttribute("PerfectJumpShopOpen", true)
	end)

	quickRail = Instance.new("Frame")
	quickRail.Name = "ConceptQuickRail"
	quickRail.AnchorPoint = Vector2.new(1, 0)
	quickRail.Position = UDim2.new(1, -20, 0, 92)
	quickRail.Size = UDim2.fromOffset(96, 96)
	quickRail.BackgroundTransparency = 1
	quickRail.Parent = gui

	local supplyQuick =
		makeButton(quickRail, "SupplyQuick", "SUPPLY", UDim2.fromOffset(96, 42), UDim2.fromOffset(0, 0), COLORS.Cyan)
	supplyQuick.Activated:Connect(function()
		player:SetAttribute("PerfectJumpShopOpen", true)
	end)

	local dailyQuick =
		makeButton(quickRail, "DailyQuick", "DAILY", UDim2.fromOffset(96, 42), UDim2.fromOffset(0, 50), COLORS.Amber)
	dailyQuick.Activated:Connect(function()
		player:SetAttribute("PerfectJumpShopOpen", true)
	end)

	tutorial = Instance.new("Frame")
	tutorial.Name = "Tutorial"
	tutorial.AnchorPoint = Vector2.new(0.5, 0)
	tutorial.Position = UDim2.new(0.5, 0, 0, 116)
	tutorial.Size = UDim2.fromOffset(440, 90)
	tutorial.BackgroundColor3 = COLORS.Foundation
	tutorial.BackgroundTransparency = 0.04
	tutorial.BorderSizePixel = 0
	tutorial.Parent = gui
	corner(tutorial, 16)
	stroke(tutorial, COLORS.Amber, 0.35, 1.4)
	local tutorialTitle = makeLabel(
		tutorial,
		"Title",
		"HOLD  •  RELEASE  •  LAND CENTER",
		UDim2.new(1, -24, 0, 30),
		UDim2.fromOffset(12, 10),
		15,
		COLORS.Text,
		Enum.Font.GothamBlack
	)
	tutorialTitle.TextXAlignment = Enum.TextXAlignment.Center
	local tutorialBody = makeLabel(
		tutorial,
		"Body",
		"Charge your jump, release, and aim for the amber precision zone.",
		UDim2.new(1, -30, 0, 36),
		UDim2.fromOffset(15, 43),
		12,
		COLORS.Muted
	)
	tutorialBody.TextWrapped = true
	tutorialBody.TextXAlignment = Enum.TextXAlignment.Center

	gradeLabel = makeLabel(
		gui,
		"LandingGrade",
		"",
		UDim2.fromOffset(300, 54),
		UDim2.new(0.5, -150, 0.33, 0),
		32,
		COLORS.Amber,
		Enum.Font.GothamBlack
	)
	gradeLabel.TextXAlignment = Enum.TextXAlignment.Center
	gradeLabel.TextTransparency = 1

	chargePanel = Instance.new("Frame")
	chargePanel.Name = "Charge"
	chargePanel.AnchorPoint = Vector2.new(0.5, 1)
	chargePanel.Position = UDim2.new(0.5, 0, 1, -28)
	chargePanel.Size = UDim2.fromOffset(460, 78)
	chargePanel.BackgroundColor3 = COLORS.Foundation
	chargePanel.BackgroundTransparency = 0.04
	chargePanel.BorderSizePixel = 0
	chargePanel.Parent = gui
	corner(chargePanel, 16)
	stroke(chargePanel, COLORS.Amber, 0.55)
	local hint = makeLabel(
		chargePanel,
		"Hint",
		"HOLD  •  RELEASE",
		UDim2.new(1, -24, 0, 28),
		UDim2.fromOffset(12, 7),
		13,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	hint.TextXAlignment = Enum.TextXAlignment.Center
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(18, 45)
	track.Size = UDim2.new(1, -36, 0, 16)
	track.BackgroundColor3 = COLORS.Panel
	track.BorderSizePixel = 0
	track.Parent = chargePanel
	corner(track, 8)
	chargeFill = Instance.new("Frame")
	chargeFill.Name = "Fill"
	chargeFill.Size = UDim2.fromScale(0, 1)
	chargeFill.BackgroundColor3 = COLORS.Amber
	chargeFill.BorderSizePixel = 0
	chargeFill.Parent = track
	corner(chargeFill, 8)

	resultPanel = Instance.new("Frame")
	resultPanel.Name = "Result"
	resultPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	resultPanel.Position = UDim2.fromScale(0.5, 0.49)
	resultPanel.Size = UDim2.fromOffset(350, 230)
	resultPanel.BackgroundColor3 = COLORS.Foundation
	resultPanel.BorderSizePixel = 0
	resultPanel.Visible = false
	resultPanel.Parent = gui
	corner(resultPanel, 20)
	stroke(resultPanel, COLORS.Fail, 0.30, 1.4)
	local resultTitle = makeLabel(
		resultPanel,
		"Title",
		"JUMP MISSED",
		UDim2.new(1, -30, 0, 42),
		UDim2.fromOffset(15, 14),
		22,
		COLORS.Text,
		Enum.Font.GothamBlack
	)
	resultTitle.TextXAlignment = Enum.TextXAlignment.Center
	resultScore = makeLabel(
		resultPanel,
		"Score",
		"SCORE  0",
		UDim2.new(1, -30, 0, 28),
		UDim2.fromOffset(15, 61),
		14,
		COLORS.Muted,
		Enum.Font.GothamBold
	)
	resultScore.TextXAlignment = Enum.TextXAlignment.Center
	local retryButton = makeButton(
		resultPanel,
		"RetryButton",
		"RETRY",
		UDim2.fromOffset(148, 50),
		UDim2.fromOffset(20, 148),
		COLORS.Cyan
	)
	retryButton.Activated:Connect(function()
		roundAction:FireServer("Retry")
	end)
	reviveButton = makeButton(
		resultPanel,
		"ReviveButton",
		"REVIVE",
		UDim2.fromOffset(148, 50),
		UDim2.fromOffset(182, 148),
		COLORS.Amber
	)
	reviveButton.Activated:Connect(function()
		local revives = tonumber(player:GetAttribute("PerfectJumpRevives")) or 0
		if revives > 0 then
			roundAction:FireServer("UseRevive")
		elseif MonetizationConfig.DeveloperProducts.Revive.ProductId > 0 then
			MarketplaceService:PromptProductPurchase(player, MonetizationConfig.DeveloperProducts.Revive.ProductId)
		end
	end)

	updateResponsive()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(updateResponsive)
	end)
end

function HudController.start()
	buildGui()

	roundState.OnClientEvent:Connect(function(payload: any)
		if type(payload) == "table" and type(payload.Grade) == "string" then
			gradeLabel.Text = string.upper(payload.Grade)
			gradeLabel.TextColor3 = if payload.Grade == "Perfect"
				then COLORS.Amber
				elseif payload.Grade == "Good" then COLORS.Cyan
				else COLORS.Text
			gradeLabel.TextTransparency = 0
			task.delay(0.7, function()
				if gradeLabel.Parent then
					gradeLabel.TextTransparency = 1
				end
			end)
		end
		refreshHud()
	end)

	for _, attribute in
		{
			"PerfectJumpScore",
			"PerfectJumpCombo",
			"PerfectJumpBestScore",
			"PerfectJumpHighestPlatform",
			"PerfectJumpCoins",
			"PerfectJumpPhase",
			"PerfectJumpCurrentPlatform",
			"PerfectJumpAssisted",
			"PerfectJumpRevives",
			"PerfectJumpTutorialComplete",
		}
	do
		player:GetAttributeChangedSignal(attribute):Connect(refreshHud)
	end

	RunService.RenderStepped:Connect(function()
		if chargeStartedAt == nil then
			return
		end
		local elapsed = os.clock() - chargeStartedAt
		local alpha = math.clamp(
			(elapsed - GameConfig.Charge.MinimumSeconds)
				/ (GameConfig.Charge.MaximumSeconds - GameConfig.Charge.MinimumSeconds),
			0,
			1
		)
		chargeFill.Size = UDim2.fromScale(alpha, 1)
	end)

	refreshHud()
end

return HudController
