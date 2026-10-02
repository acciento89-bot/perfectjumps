--!strict

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local GameConfig = require(shared.config.GameConfig)
local MonetizationConfig = require(shared.config.MonetizationConfig)

local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundAction = remotes:WaitForChild("RoundAction") :: RemoteEvent
local roundState = remotes:WaitForChild("RoundState") :: RemoteEvent
local requestMeta = remotes:WaitForChild("RequestMetaState") :: RemoteFunction
local purchaseCosmetic = remotes:WaitForChild("PurchaseCosmetic") :: RemoteFunction
local equipCosmetic = remotes:WaitForChild("EquipCosmetic") :: RemoteFunction
local claimDaily = remotes:WaitForChild("ClaimDaily") :: RemoteFunction
local setSetting = remotes:WaitForChild("SetSetting") :: RemoteFunction
local metaChanged = remotes:WaitForChild("MetaStateChanged") :: RemoteEvent

local HudController = {}

local COLORS = {
	Foundation = Color3.fromRGB(18, 23, 31),
	Panel = Color3.fromRGB(30, 38, 50),
	PanelSoft = Color3.fromRGB(42, 51, 65),
	Text = Color3.fromRGB(245, 248, 252),
	Muted = Color3.fromRGB(166, 178, 194),
	Amber = Color3.fromRGB(255, 178, 72),
	Cyan = Color3.fromRGB(91, 220, 239),
	Green = Color3.fromRGB(105, 214, 151),
	Fail = Color3.fromRGB(255, 100, 112),
}

local chargeStartedAt: number? = nil
local profile: any = nil
local gui: ScreenGui
local responsiveScale: UIScale
local statsPanel: Frame
local scoreLabel: TextLabel
local comboLabel: TextLabel
local bestLabel: TextLabel
local coinsLabel: TextLabel
local platformLabel: TextLabel
local phaseLabel: TextLabel
local chargePanel: Frame
local chargeFill: Frame
local tutorial: Frame
local gradeLabel: TextLabel
local resultPanel: Frame
local resultScore: TextLabel
local reviveButton: TextButton
local shopButton: TextButton
local shopDimmer: Frame
local shopPanel: Frame
local dailyButton: TextButton
local dailyDetail: TextLabel
local challengeDetail: TextLabel
local reducedMotionButton: TextButton
local audioButton: TextButton
local cosmeticButtons: { [string]: { [string]: TextButton } } = {}

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function stroke(parent: Instance, color: Color3, transparency: number, thickness: number?)
	local item = Instance.new("UIStroke")
	item.Thickness = thickness or 1
	item.Transparency = transparency
	item.Color = color
	item.Parent = parent
end

local function gradient(parent: Instance, first: Color3, second: Color3, rotation: number?)
	local item = Instance.new("UIGradient")
	item.Color = ColorSequence.new(first, second)
	item.Rotation = rotation or 90
	item.Parent = parent
end

local function label(
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
	item.BackgroundTransparency = 1
	item.Size = size
	item.Position = position
	item.Font = font or Enum.Font.GothamMedium
	item.Text = text
	item.TextSize = textSize
	item.TextColor3 = color
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function button(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	background: Color3,
	textColor: Color3
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
	item.TextColor3 = textColor
	item.AutoButtonColor = true
	item.Selectable = true
	item.Parent = parent
	corner(item, 12)
	return item
end

local function colorFromRgb(values): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function currentPhase(): string
	local value = player:GetAttribute("PerfectJumpPhase")
	return if type(value) == "string" then value else "Ready"
end

local function setShopOpen(open: boolean)
	player:SetAttribute("PerfectJumpUiModal", open)
	shopDimmer.Visible = open
	shopPanel.Visible = open
	if open then
		GuiService.SelectedObject = shopPanel:FindFirstChild("CloseButton") :: GuiObject?
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(shopPanel) then
		GuiService.SelectedObject = shopButton
	end
end

local function updateResponsive()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local width = camera.ViewportSize.X
	responsiveScale.Scale = math.clamp(width / 980, 0.80, 1.06)
	if width <= 760 then
		statsPanel.Position = UDim2.fromOffset(12, 12)
		statsPanel.Size = UDim2.fromOffset(290, 84)
		shopButton.Position = UDim2.new(1, -112, 0, 112)
		chargePanel.Size = UDim2.new(1, -36, 0, 78)
		tutorial.Size = UDim2.new(1, -30, 0, 90)
	elseif width <= 1100 then
		statsPanel.Position = UDim2.fromOffset(16, 16)
		statsPanel.Size = UDim2.fromOffset(390, 84)
		shopButton.Position = UDim2.new(1, -124, 0, 18)
		chargePanel.Size = UDim2.fromOffset(460, 78)
		tutorial.Size = UDim2.fromOffset(430, 90)
	else
		statsPanel.Position = UDim2.fromOffset(20, 20)
		statsPanel.Size = UDim2.fromOffset(440, 84)
		shopButton.Position = UDim2.new(1, -132, 0, 22)
		chargePanel.Size = UDim2.fromOffset(460, 78)
		tutorial.Size = UDim2.fromOffset(440, 90)
	end
end

local function updateCosmeticButtons()
	if not profile then
		return
	end

	for category, buttons in cosmeticButtons do
		local categoryProfile = profile.Owned and profile.Owned[category]
		local equipped = profile.Equipped and profile.Equipped[category]
		for itemId, itemButton in buttons do
			local owned = categoryProfile and categoryProfile[itemId] == true
			if equipped == itemId then
				itemButton.Text = "EQUIPPED"
				itemButton.BackgroundColor3 = COLORS.Green
			elseif owned then
				itemButton.Text = "EQUIP"
				itemButton.BackgroundColor3 = COLORS.Cyan
			else
				local item = CosmeticConfig.Categories[category].Items[itemId]
				itemButton.Text = ("BUY  ◈%d"):format(item.Price)
				itemButton.BackgroundColor3 = COLORS.Amber
			end
		end
	end
end

local function updateProfile(nextProfile: any)
	if type(nextProfile) ~= "table" then
		return
	end
	profile = nextProfile

	local coins = tonumber(profile.Coins) or 0
	coinsLabel.Text = ("◈ %d"):format(coins)

	if profile.DailyClaimable == true then
		dailyButton.Text = "CLAIM"
		dailyButton.Active = true
		dailyButton.BackgroundColor3 = COLORS.Amber
		dailyDetail.Text = "Daily precision supply is ready."
	else
		dailyButton.Text = "CLAIMED"
		dailyButton.Active = false
		dailyButton.BackgroundColor3 = COLORS.PanelSoft
		dailyDetail.Text = "Come back after the daily reset."
	end

	local dailyPerfects = tonumber(profile.DailyPerfects) or 0
	local dailyRequired = tonumber(profile.DailyRequired) or 5
	challengeDetail.Text = if profile.DailyRewarded == true
		then "Complete  •  reward collected"
		else ("Land %d Perfect jumps  •  %d/%d"):format(dailyRequired, dailyPerfects, dailyRequired)

	reducedMotionButton.Text = if profile.Settings and profile.Settings.ReducedMotion == true then "ON" else "OFF"
	audioButton.Text = if not profile.Settings or profile.Settings.AudioEnabled ~= false then "ON" else "OFF"
	updateCosmeticButtons()
end

local function requestProfile()
	task.spawn(function()
		local ok, result = pcall(function()
			return requestMeta:InvokeServer()
		end)
		if ok and type(result) == "table" and result.ok == true then
			updateProfile(result.meta)
		end
	end)
end

local function refreshHud()
	local score = tonumber(player:GetAttribute("PerfectJumpScore")) or 0
	local combo = tonumber(player:GetAttribute("PerfectJumpCombo")) or 0
	local best = tonumber(player:GetAttribute("PerfectJumpBestScore")) or 0
	local highest = tonumber(player:GetAttribute("PerfectJumpHighestPlatform")) or 0
	local currentPlatform = tonumber(player:GetAttribute("PerfectJumpCurrentPlatform")) or 0
	local phase = currentPhase()
	local assisted = player:GetAttribute("PerfectJumpAssisted") == true
	local revives = tonumber(player:GetAttribute("PerfectJumpRevives")) or 0

	scoreLabel.Text = ("SCORE  %d"):format(score)
	comboLabel.Text = ("COMBO  %d"):format(combo)
	bestLabel.Text = ("PB  %d"):format(best)
	platformLabel.Text = ("PLATFORM  %d   •   HIGH  %d"):format(currentPlatform, highest)
	phaseLabel.Text = if assisted then string.upper(phase) .. "  •  ASSISTED" else string.upper(phase)

	resultPanel.Visible = phase == "GameOver"
	chargePanel.Visible = phase ~= "GameOver"
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

	tutorial.Visible = player:GetAttribute("PerfectJumpTutorialComplete") ~= true and phase ~= "GameOver"
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

local function addCosmeticSection(scroll: ScrollingFrame, category: string, titleText: string, order: number): number
	local title = label(
		scroll,
		category .. "Title",
		titleText,
		UDim2.new(1, -8, 0, 28),
		UDim2.new(),
		12,
		COLORS.Muted,
		Enum.Font.GothamBold
	)
	title.LayoutOrder = order
	title.ZIndex = 53
	order += 1

	cosmeticButtons[category] = {}
	local definition = CosmeticConfig.Categories[category]
	local ids = {}
	for itemId in definition.Items do
		table.insert(ids, itemId)
	end
	table.sort(ids)

	for _, itemId in ids do
		local item = definition.Items[itemId]
		local row = Instance.new("Frame")
		row.Name = category .. "_" .. itemId
		row.Size = UDim2.new(1, -8, 0, 68)
		row.BackgroundColor3 = COLORS.Panel
		row.BackgroundTransparency = 0.04
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.ZIndex = 53
		row.Parent = scroll
		corner(row, 13)
		order += 1

		local swatch = Instance.new("Frame")
		swatch.Name = "Swatch"
		swatch.Position = UDim2.fromOffset(12, 12)
		swatch.Size = UDim2.fromOffset(44, 44)
		swatch.BorderSizePixel = 0
		swatch.BackgroundColor3 = if item.RGB
			then colorFromRgb(item.RGB)
			elseif item.AccentRGB then colorFromRgb(item.AccentRGB)
			else COLORS.Cyan
		swatch.ZIndex = 54
		swatch.Parent = row
		corner(swatch, 11)
		stroke(swatch, COLORS.Text, 0.65)

		local nameLabel = label(
			row,
			"Name",
			item.DisplayName,
			UDim2.new(1, -190, 0, 28),
			UDim2.fromOffset(68, 8),
			13,
			COLORS.Text,
			Enum.Font.GothamBold
		)
		nameLabel.ZIndex = 54
		local priceLabel = label(
			row,
			"Price",
			if item.Price == 0 then "Included" else ("◈ %d"):format(item.Price),
			UDim2.new(1, -190, 0, 22),
			UDim2.fromOffset(68, 36),
			11,
			COLORS.Muted
		)
		priceLabel.ZIndex = 54

		local action = button(
			row,
			"Action",
			"BUY",
			UDim2.fromOffset(104, 42),
			UDim2.new(1, -116, 0.5, -21),
			COLORS.Amber,
			COLORS.Foundation
		)
		action.ZIndex = 54
		cosmeticButtons[category][itemId] = action

		action.Activated:Connect(function()
			if not profile then
				return
			end
			local owned = profile.Owned and profile.Owned[category] and profile.Owned[category][itemId] == true
			task.spawn(function()
				local ok, result = pcall(function()
					if owned then
						return equipCosmetic:InvokeServer(category, itemId)
					end
					return purchaseCosmetic:InvokeServer(category, itemId)
				end)
				if ok and type(result) == "table" and result.meta then
					updateProfile(result.meta)
				end
			end)
		end)
	end

	return order
end

local function buildGui()
	local existing = playerGui:FindFirstChild("PerfectJumpHUD")
	if existing then
		existing:Destroy()
	end

	gui = Instance.new("ScreenGui")
	gui.Name = "PerfectJumpHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 20
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	responsiveScale = Instance.new("UIScale")
	responsiveScale.Name = "ResponsiveScale"
	responsiveScale.Parent = gui

	statsPanel = Instance.new("Frame")
	statsPanel.Name = "Stats"
	statsPanel.Size = UDim2.fromOffset(440, 84)
	statsPanel.BackgroundColor3 = COLORS.Foundation
	statsPanel.BackgroundTransparency = 0.04
	statsPanel.BorderSizePixel = 0
	statsPanel.Parent = gui
	corner(statsPanel, 16)
	stroke(statsPanel, COLORS.Cyan, 0.64)
	gradient(statsPanel, COLORS.Foundation, COLORS.Panel, 110)

	scoreLabel = label(statsPanel, "Score", "SCORE  0", UDim2.fromOffset(128, 27), UDim2.fromOffset(14, 8), 15, COLORS.Text, Enum.Font.GothamBold)
	comboLabel = label(statsPanel, "Combo", "COMBO  0", UDim2.fromOffset(128, 27), UDim2.fromOffset(146, 8), 15, COLORS.Text, Enum.Font.GothamBold)
	bestLabel = label(statsPanel, "Best", "PB  0", UDim2.fromOffset(92, 27), UDim2.fromOffset(278, 8), 15, COLORS.Amber, Enum.Font.GothamBold)
	coinsLabel = label(statsPanel, "Coins", "◈ 0", UDim2.fromOffset(72, 27), UDim2.new(1, -82, 0, 8), 14, COLORS.Amber, Enum.Font.GothamBold)
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
	platformLabel = label(statsPanel, "Platform", "PLATFORM  0", UDim2.fromOffset(230, 24), UDim2.fromOffset(14, 48), 12, COLORS.Muted, Enum.Font.GothamBold)
	phaseLabel = label(statsPanel, "Phase", "READY", UDim2.new(1, -258, 0, 24), UDim2.fromOffset(244, 48), 12, COLORS.Cyan, Enum.Font.GothamBold)
	phaseLabel.TextXAlignment = Enum.TextXAlignment.Right

	shopButton = button(gui, "ShopButton", "SUPPLY", UDim2.fromOffset(110, 46), UDim2.new(1, -132, 0, 22), COLORS.Cyan, COLORS.Foundation)
	shopButton.Activated:Connect(function()
		setShopOpen(true)
		requestProfile()
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
	local tutorialTitle = label(tutorial, "Title", "HOLD  •  RELEASE  •  LAND CENTER", UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 10), 15, COLORS.Text, Enum.Font.GothamBlack)
	tutorialTitle.TextXAlignment = Enum.TextXAlignment.Center
	local tutorialBody = label(tutorial, "Body", "Charge your jump, release, and aim for the amber precision zone.", UDim2.new(1, -30, 0, 36), UDim2.fromOffset(15, 43), 12, COLORS.Muted)
	tutorialBody.TextWrapped = true
	tutorialBody.TextXAlignment = Enum.TextXAlignment.Center

	gradeLabel = label(gui, "LandingGrade", "", UDim2.fromOffset(300, 54), UDim2.new(0.5, -150, 0.33, 0), 32, COLORS.Amber, Enum.Font.GothamBlack)
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

	local hint = label(chargePanel, "Hint", "HOLD  •  RELEASE", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 7), 13, COLORS.Text, Enum.Font.GothamBold)
	hint.TextXAlignment = Enum.TextXAlignment.Center
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(18, 45)
	track.Size = UDim2.new(1, -36, 0, 16)
	track.BackgroundColor3 = COLORS.PanelSoft
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
	gradient(chargeFill, COLORS.Amber, COLORS.Cyan, 0)

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
	gradient(resultPanel, COLORS.Foundation, COLORS.Panel, 120)

	local resultTitle = label(resultPanel, "Title", "JUMP MISSED", UDim2.new(1, -30, 0, 42), UDim2.fromOffset(15, 14), 22, COLORS.Text, Enum.Font.GothamBlack)
	resultTitle.TextXAlignment = Enum.TextXAlignment.Center
	resultScore = label(resultPanel, "Score", "SCORE  0", UDim2.new(1, -30, 0, 28), UDim2.fromOffset(15, 61), 14, COLORS.Muted, Enum.Font.GothamBold)
	resultScore.TextXAlignment = Enum.TextXAlignment.Center
	local retryButton = button(resultPanel, "RetryButton", "RETRY", UDim2.fromOffset(148, 50), UDim2.fromOffset(20, 148), COLORS.Cyan, COLORS.Foundation)
	retryButton.Activated:Connect(function()
		roundAction:FireServer("Retry")
	end)
	reviveButton = button(resultPanel, "ReviveButton", "REVIVE", UDim2.fromOffset(148, 50), UDim2.fromOffset(182, 148), COLORS.Amber, COLORS.Foundation)
	reviveButton.Activated:Connect(function()
		local revives = tonumber(player:GetAttribute("PerfectJumpRevives")) or 0
		if revives > 0 then
			roundAction:FireServer("UseRevive")
			return
		end
		local productId = MonetizationConfig.DeveloperProducts.Revive.ProductId
		if productId > 0 then
			MarketplaceService:PromptProductPurchase(player, productId)
		end
	end)

	shopDimmer = Instance.new("Frame")
	shopDimmer.Name = "ShopDimmer"
	shopDimmer.Size = UDim2.fromScale(1, 1)
	shopDimmer.BackgroundColor3 = Color3.fromRGB(4, 7, 11)
	shopDimmer.BackgroundTransparency = 0.25
	shopDimmer.BorderSizePixel = 0
	shopDimmer.Visible = false
	shopDimmer.ZIndex = 50
	shopDimmer.Parent = gui

	shopPanel = Instance.new("Frame")
	shopPanel.Name = "ShopPanel"
	shopPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	shopPanel.Position = UDim2.fromScale(0.5, 0.5)
	shopPanel.Size = UDim2.fromScale(0.88, 0.86)
	shopPanel.BackgroundColor3 = COLORS.Foundation
	shopPanel.BorderSizePixel = 0
	shopPanel.Visible = false
	shopPanel.ZIndex = 51
	shopPanel.Parent = gui
	corner(shopPanel, 20)
	stroke(shopPanel, COLORS.Cyan, 0.40, 1.2)
	gradient(shopPanel, COLORS.Foundation, COLORS.Panel, 120)

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(310, 450)
	constraint.MaxSize = Vector2.new(520, 700)
	constraint.Parent = shopPanel

	local shopTitle = label(shopPanel, "Title", "PRECISION SUPPLY", UDim2.new(1, -92, 0, 48), UDim2.fromOffset(20, 10), 20, COLORS.Text, Enum.Font.GothamBlack)
	shopTitle.ZIndex = 52
	local closeButton = button(shopPanel, "CloseButton", "×", UDim2.fromOffset(46, 46), UDim2.new(1, -60, 0, 12), COLORS.PanelSoft, COLORS.Text)
	closeButton.TextSize = 23
	closeButton.ZIndex = 52
	closeButton.Activated:Connect(function()
		setShopOpen(false)
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Content"
	scroll.Position = UDim2.fromOffset(14, 66)
	scroll.Size = UDim2.new(1, -28, 1, -80)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = COLORS.Cyan
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ZIndex = 52
	scroll.Parent = shopPanel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 9)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = scroll

	local dailyCard = Instance.new("Frame")
	dailyCard.Name = "Daily"
	dailyCard.Size = UDim2.new(1, -8, 0, 92)
	dailyCard.BackgroundColor3 = COLORS.Panel
	dailyCard.BorderSizePixel = 0
	dailyCard.LayoutOrder = 1
	dailyCard.ZIndex = 53
	dailyCard.Parent = scroll
	corner(dailyCard, 14)
	stroke(dailyCard, COLORS.Amber, 0.58)
	local dailyTitle = label(dailyCard, "Title", "DAILY SUPPLY", UDim2.new(1, -148, 0, 28), UDim2.fromOffset(14, 8), 13, COLORS.Text, Enum.Font.GothamBold)
	dailyTitle.ZIndex = 54
	dailyDetail = label(dailyCard, "Detail", "Loading…", UDim2.new(1, -148, 0, 40), UDim2.fromOffset(14, 37), 11, COLORS.Muted)
	dailyDetail.TextWrapped = true
	dailyDetail.ZIndex = 54
	dailyButton = button(dailyCard, "Claim", "CLAIM", UDim2.fromOffset(112, 46), UDim2.new(1, -126, 0.5, -23), COLORS.Amber, COLORS.Foundation)
	dailyButton.ZIndex = 54
	dailyButton.Activated:Connect(function()
		if not dailyButton.Active then
			return
		end
		task.spawn(function()
			local ok, result = pcall(function()
				return claimDaily:InvokeServer()
			end)
			if ok and type(result) == "table" and result.meta then
				updateProfile(result.meta)
			end
		end)
	end)

	local challengeCard = Instance.new("Frame")
	challengeCard.Name = "Challenge"
	challengeCard.Size = UDim2.new(1, -8, 0, 72)
	challengeCard.BackgroundColor3 = COLORS.Panel
	challengeCard.BorderSizePixel = 0
	challengeCard.LayoutOrder = 2
	challengeCard.ZIndex = 53
	challengeCard.Parent = scroll
	corner(challengeCard, 14)
	local challengeTitle = label(challengeCard, "Title", "DAILY PRECISION", UDim2.new(1, -28, 0, 27), UDim2.fromOffset(14, 6), 12, COLORS.Text, Enum.Font.GothamBold)
	challengeTitle.ZIndex = 54
	challengeDetail = label(challengeCard, "Detail", "Loading…", UDim2.new(1, -28, 0, 30), UDim2.fromOffset(14, 33), 11, COLORS.Muted)
	challengeDetail.ZIndex = 54

	local assistTitle = label(scroll, "AssistsTitle", "ASSISTS — assisted runs do not improve PB", UDim2.new(1, -8, 0, 28), UDim2.new(), 11, COLORS.Muted, Enum.Font.GothamBold)
	assistTitle.LayoutOrder = 10
	assistTitle.ZIndex = 53

	local assistCard = Instance.new("Frame")
	assistCard.Name = "Assists"
	assistCard.Size = UDim2.new(1, -8, 0, 132)
	assistCard.BackgroundColor3 = COLORS.Panel
	assistCard.BorderSizePixel = 0
	assistCard.LayoutOrder = 11
	assistCard.ZIndex = 53
	assistCard.Parent = scroll
	corner(assistCard, 14)
	local assistDetail = label(
		assistCard,
		"Detail",
		("Revive %d R$  •  Wider Perfect %d R$ / 5m  •  2× Coins %d R$ / 15m"):format(
			MonetizationConfig.DeveloperProducts.Revive.Robux,
			MonetizationConfig.DeveloperProducts.WidePerfect5m.Robux,
			MonetizationConfig.DeveloperProducts.CoinBoost15m.Robux
		),
		UDim2.new(1, -28, 0, 38),
		UDim2.fromOffset(14, 8),
		11,
		COLORS.Muted
	)
	assistDetail.TextWrapped = true
	assistDetail.ZIndex = 54

	local productKeys = { "Revive", "WidePerfect5m", "CoinBoost15m" }
	local productNames = { "REVIVE", "WIDE ZONE", "2× COINS" }
	for index, key in productKeys do
		local product = MonetizationConfig.DeveloperProducts[key]
		local productButton = button(
			assistCard,
			"Buy" .. key,
			productNames[index],
			UDim2.new(1 / 3, -13, 0, 46),
			UDim2.new((index - 1) / 3, 10 + (index - 1) * 2, 0, 70),
			if index == 1 then COLORS.Amber else COLORS.Cyan,
			COLORS.Foundation
		)
		productButton.ZIndex = 54
		productButton.Activated:Connect(function()
			if product.ProductId > 0 then
				MarketplaceService:PromptProductPurchase(player, product.ProductId)
			end
		end)
	end

	local order = 20
	order = addCosmeticSection(scroll, "Trails", "TRAILS", order)
	order = addCosmeticSection(scroll, "LandingEffects", "LANDING EFFECTS", order)
	order = addCosmeticSection(scroll, "PlatformThemes", "PLATFORM THEMES", order)
	order = addCosmeticSection(scroll, "EnvironmentThemes", "ENVIRONMENT THEMES", order)

	local settingsTitle = label(scroll, "SettingsTitle", "ACCESSIBILITY", UDim2.new(1, -8, 0, 28), UDim2.new(), 11, COLORS.Muted, Enum.Font.GothamBold)
	settingsTitle.LayoutOrder = order
	settingsTitle.ZIndex = 53
	order += 1

	local settings = Instance.new("Frame")
	settings.Name = "Settings"
	settings.Size = UDim2.new(1, -8, 0, 116)
	settings.BackgroundColor3 = COLORS.Panel
	settings.BorderSizePixel = 0
	settings.LayoutOrder = order
	settings.ZIndex = 53
	settings.Parent = scroll
	corner(settings, 14)
	local reducedLabel = label(settings, "ReducedLabel", "Reduced motion", UDim2.new(1, -140, 0, 48), UDim2.fromOffset(14, 6), 12, COLORS.Text, Enum.Font.GothamBold)
	reducedLabel.ZIndex = 54
	reducedMotionButton = button(settings, "ReducedMotion", "OFF", UDim2.fromOffset(96, 42), UDim2.new(1, -110, 0, 9), COLORS.PanelSoft, COLORS.Text)
	reducedMotionButton.ZIndex = 54
	local audioLabel = label(settings, "AudioLabel", "Audio", UDim2.new(1, -140, 0, 48), UDim2.fromOffset(14, 60), 12, COLORS.Text, Enum.Font.GothamBold)
	audioLabel.ZIndex = 54
	audioButton = button(settings, "Audio", "ON", UDim2.fromOffset(96, 42), UDim2.new(1, -110, 0, 63), COLORS.PanelSoft, COLORS.Text)
	audioButton.ZIndex = 54

	reducedMotionButton.Activated:Connect(function()
		local enabled = not (profile and profile.Settings and profile.Settings.ReducedMotion == true)
		task.spawn(function()
			local ok, result = pcall(function()
				return setSetting:InvokeServer("ReducedMotion", enabled)
			end)
			if ok and type(result) == "table" and result.meta then
				updateProfile(result.meta)
			end
		end)
	end)

	audioButton.Activated:Connect(function()
		local enabled = not (profile and profile.Settings and profile.Settings.AudioEnabled ~= false)
		task.spawn(function()
			local ok, result = pcall(function()
				return setSetting:InvokeServer("AudioEnabled", enabled)
			end)
			if ok and type(result) == "table" and result.meta then
				updateProfile(result.meta)
			end
		end)
	end)

	ContextActionService:BindActionAtPriority(
		"PerfectJumpShop",
		function(_name, state)
			if state == Enum.UserInputState.Begin then
				setShopOpen(not shopPanel.Visible)
				if shopPanel.Visible then
					requestProfile()
				end
			end
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.ContextActionPriority.High.Value + 60,
		Enum.KeyCode.ButtonY
	)

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

	metaChanged.OnClientEvent:Connect(updateProfile)

	for _, attribute in {
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
	} do
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
	requestProfile()
end

return HudController
