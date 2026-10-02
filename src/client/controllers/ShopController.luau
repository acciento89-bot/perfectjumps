--!strict

local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local MonetizationConfig = require(shared.config.MonetizationConfig)

local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local requestMeta = remotes:WaitForChild("RequestMetaState") :: RemoteFunction
local purchaseCosmetic = remotes:WaitForChild("PurchaseCosmetic") :: RemoteFunction
local equipCosmetic = remotes:WaitForChild("EquipCosmetic") :: RemoteFunction
local claimDaily = remotes:WaitForChild("ClaimDaily") :: RemoteFunction
local setSetting = remotes:WaitForChild("SetSetting") :: RemoteFunction
local metaChanged = remotes:WaitForChild("MetaStateChanged") :: RemoteEvent

local ShopController = {}

local COLORS = {
	Foundation = Color3.fromRGB(18, 23, 31),
	Panel = Color3.fromRGB(30, 38, 50),
	PanelSoft = Color3.fromRGB(42, 51, 65),
	Text = Color3.fromRGB(245, 248, 252),
	Muted = Color3.fromRGB(166, 178, 194),
	Amber = Color3.fromRGB(255, 178, 72),
	Cyan = Color3.fromRGB(91, 220, 239),
	Green = Color3.fromRGB(105, 214, 151),
}

local profile: any = nil
local dimmer: Frame
local panel: Frame
local closeButton: TextButton
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

local function stroke(parent: Instance, color: Color3, transparency: number)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Transparency = transparency
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
	item.TextSize = 13
	item.TextColor3 = COLORS.Foundation
	item.AutoButtonColor = true
	item.Selectable = true
	item.Parent = parent
	corner(item, 11)
	return item
end

local function rgb(values): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function setOpen(open: boolean)
	player:SetAttribute("PerfectJumpShopOpen", open)
	player:SetAttribute("PerfectJumpUiModal", open)
	dimmer.Visible = open
	panel.Visible = open
	if open then
		GuiService.SelectedObject = closeButton
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
		GuiService.SelectedObject = nil
	end
end

local function updateCosmetics()
	if not profile then
		return
	end
	for category, buttons in cosmeticButtons do
		for itemId, itemButton in buttons do
			local owned = profile.Owned and profile.Owned[category] and profile.Owned[category][itemId] == true
			local equipped = profile.Equipped and profile.Equipped[category] == itemId
			local item = CosmeticConfig.Categories[category].Items[itemId]
			if equipped then
				itemButton.Text = "EQUIPPED"
				itemButton.BackgroundColor3 = COLORS.Green
			elseif owned then
				itemButton.Text = "EQUIP"
				itemButton.BackgroundColor3 = COLORS.Cyan
			else
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

	local progress = tonumber(profile.DailyPerfects) or 0
	local target = tonumber(profile.DailyRequired) or 5
	challengeDetail.Text = if profile.DailyRewarded == true
		then "Complete  •  reward collected"
		else ("Land %d Perfect jumps  •  %d/%d"):format(target, progress, target)

	reducedMotionButton.Text = if profile.Settings and profile.Settings.ReducedMotion == true then "ON" else "OFF"
	audioButton.Text = if not profile.Settings or profile.Settings.AudioEnabled ~= false then "ON" else "OFF"
	updateCosmetics()
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

local function addSectionTitle(scroll: ScrollingFrame, text: string, order: number)
	local item = makeLabel(
		scroll,
		"Section_" .. tostring(order),
		text,
		UDim2.new(1, -8, 0, 26),
		UDim2.new(),
		11,
		COLORS.Muted,
		Enum.Font.GothamBold
	)
	item.LayoutOrder = order
	item.ZIndex = 53
end

local function addCosmeticSection(scroll: ScrollingFrame, category: string, title: string, order: number): number
	addSectionTitle(scroll, title, order)
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
		row.Size = UDim2.new(1, -8, 0, 66)
		row.BackgroundColor3 = COLORS.Panel
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.ZIndex = 53
		row.Parent = scroll
		corner(row, 12)
		order += 1

		local swatch = Instance.new("Frame")
		swatch.Name = "Swatch"
		swatch.Size = UDim2.fromOffset(42, 42)
		swatch.Position = UDim2.fromOffset(12, 12)
		swatch.BorderSizePixel = 0
		swatch.BackgroundColor3 = if item.RGB
			then rgb(item.RGB)
			elseif item.AccentRGB then rgb(item.AccentRGB)
			else COLORS.Cyan
		swatch.ZIndex = 54
		swatch.Parent = row
		corner(swatch, 10)
		stroke(swatch, COLORS.Text, 0.68)

		local titleLabel = makeLabel(
			row,
			"Title",
			item.DisplayName,
			UDim2.new(1, -190, 0, 26),
			UDim2.fromOffset(66, 8),
			12,
			COLORS.Text,
			Enum.Font.GothamBold
		)
		titleLabel.ZIndex = 54
		local priceLabel = makeLabel(
			row,
			"Price",
			if item.Price == 0 then "Included" else ("◈ %d"):format(item.Price),
			UDim2.new(1, -190, 0, 22),
			UDim2.fromOffset(66, 35),
			11,
			COLORS.Muted
		)
		priceLabel.ZIndex = 54

		local action =
			makeButton(row, "Action", "BUY", UDim2.fromOffset(104, 40), UDim2.new(1, -116, 0.5, -20), COLORS.Amber)
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
	local hud = playerGui:WaitForChild("PerfectJumpHUD") :: ScreenGui

	dimmer = Instance.new("Frame")
	dimmer.Name = "ShopDimmer"
	dimmer.Size = UDim2.fromScale(1, 1)
	dimmer.BackgroundColor3 = Color3.fromRGB(4, 7, 11)
	dimmer.BackgroundTransparency = 0.24
	dimmer.BorderSizePixel = 0
	dimmer.Visible = false
	dimmer.ZIndex = 50
	dimmer.Parent = hud

	panel = Instance.new("Frame")
	panel.Name = "ShopPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.88, 0.86)
	panel.BackgroundColor3 = COLORS.Foundation
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 51
	panel.Parent = hud
	corner(panel, 20)
	stroke(panel, COLORS.Cyan, 0.40)

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(310, 450)
	constraint.MaxSize = Vector2.new(520, 700)
	constraint.Parent = panel

	local title = makeLabel(
		panel,
		"Title",
		"PRECISION SUPPLY",
		UDim2.new(1, -90, 0, 48),
		UDim2.fromOffset(20, 10),
		20,
		COLORS.Text,
		Enum.Font.GothamBlack
	)
	title.ZIndex = 52
	closeButton =
		makeButton(panel, "CloseButton", "×", UDim2.fromOffset(46, 46), UDim2.new(1, -60, 0, 12), COLORS.PanelSoft)
	closeButton.TextColor3 = COLORS.Text
	closeButton.TextSize = 22
	closeButton.ZIndex = 52
	closeButton.Activated:Connect(function()
		setOpen(false)
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
	scroll.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 9)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = scroll

	local daily = Instance.new("Frame")
	daily.Name = "Daily"
	daily.Size = UDim2.new(1, -8, 0, 90)
	daily.BackgroundColor3 = COLORS.Panel
	daily.BorderSizePixel = 0
	daily.LayoutOrder = 1
	daily.ZIndex = 53
	daily.Parent = scroll
	corner(daily, 13)
	stroke(daily, COLORS.Amber, 0.60)
	local dailyTitle = makeLabel(
		daily,
		"Title",
		"DAILY SUPPLY",
		UDim2.new(1, -145, 0, 27),
		UDim2.fromOffset(14, 8),
		13,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	dailyTitle.ZIndex = 54
	dailyDetail =
		makeLabel(daily, "Detail", "Loading…", UDim2.new(1, -145, 0, 38), UDim2.fromOffset(14, 36), 11, COLORS.Muted)
	dailyDetail.TextWrapped = true
	dailyDetail.ZIndex = 54
	dailyButton =
		makeButton(daily, "Claim", "CLAIM", UDim2.fromOffset(108, 44), UDim2.new(1, -122, 0.5, -22), COLORS.Amber)
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

	local challenge = Instance.new("Frame")
	challenge.Name = "Challenge"
	challenge.Size = UDim2.new(1, -8, 0, 70)
	challenge.BackgroundColor3 = COLORS.Panel
	challenge.BorderSizePixel = 0
	challenge.LayoutOrder = 2
	challenge.ZIndex = 53
	challenge.Parent = scroll
	corner(challenge, 13)
	local challengeTitle = makeLabel(
		challenge,
		"Title",
		"DAILY PRECISION",
		UDim2.new(1, -28, 0, 26),
		UDim2.fromOffset(14, 6),
		12,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	challengeTitle.ZIndex = 54
	challengeDetail = makeLabel(
		challenge,
		"Detail",
		"Loading…",
		UDim2.new(1, -28, 0, 30),
		UDim2.fromOffset(14, 32),
		11,
		COLORS.Muted
	)
	challengeDetail.ZIndex = 54

	addSectionTitle(scroll, "ASSISTS — assisted runs do not improve PB", 10)
	local assists = Instance.new("Frame")
	assists.Name = "Assists"
	assists.Size = UDim2.new(1, -8, 0, 128)
	assists.BackgroundColor3 = COLORS.Panel
	assists.BorderSizePixel = 0
	assists.LayoutOrder = 11
	assists.ZIndex = 53
	assists.Parent = scroll
	corner(assists, 13)
	local assistText = makeLabel(
		assists,
		"Detail",
		("Revive %d R$  •  Wider Perfect %d R$ / 5m  •  2× Coins %d R$ / 15m"):format(
			MonetizationConfig.DeveloperProducts.Revive.Robux,
			MonetizationConfig.DeveloperProducts.WidePerfect5m.Robux,
			MonetizationConfig.DeveloperProducts.CoinBoost15m.Robux
		),
		UDim2.new(1, -28, 0, 38),
		UDim2.fromOffset(14, 7),
		11,
		COLORS.Muted
	)
	assistText.TextWrapped = true
	assistText.ZIndex = 54

	local keys = { "Revive", "WidePerfect5m", "CoinBoost15m" }
	local names = { "REVIVE", "WIDE ZONE", "2× COINS" }
	for index, key in keys do
		local product = MonetizationConfig.DeveloperProducts[key]
		local buy = makeButton(
			assists,
			"Buy" .. key,
			names[index],
			UDim2.new(1 / 3, -12, 0, 44),
			UDim2.new((index - 1) / 3, 8 + (index - 1) * 2, 0, 68),
			if index == 1 then COLORS.Amber else COLORS.Cyan
		)
		buy.ZIndex = 54
		buy.Activated:Connect(function()
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

	addSectionTitle(scroll, "ACCESSIBILITY", order)
	order += 1
	local settings = Instance.new("Frame")
	settings.Name = "Settings"
	settings.Size = UDim2.new(1, -8, 0, 110)
	settings.BackgroundColor3 = COLORS.Panel
	settings.BorderSizePixel = 0
	settings.LayoutOrder = order
	settings.ZIndex = 53
	settings.Parent = scroll
	corner(settings, 13)
	local reducedLabel = makeLabel(
		settings,
		"ReducedLabel",
		"Reduced motion",
		UDim2.new(1, -140, 0, 46),
		UDim2.fromOffset(14, 5),
		12,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	reducedLabel.ZIndex = 54
	reducedMotionButton = makeButton(
		settings,
		"ReducedMotion",
		"OFF",
		UDim2.fromOffset(94, 40),
		UDim2.new(1, -108, 0, 8),
		COLORS.PanelSoft
	)
	reducedMotionButton.TextColor3 = COLORS.Text
	reducedMotionButton.ZIndex = 54
	local audioLabel = makeLabel(
		settings,
		"AudioLabel",
		"Audio",
		UDim2.new(1, -140, 0, 46),
		UDim2.fromOffset(14, 57),
		12,
		COLORS.Text,
		Enum.Font.GothamBold
	)
	audioLabel.ZIndex = 54
	audioButton =
		makeButton(settings, "Audio", "ON", UDim2.fromOffset(94, 40), UDim2.new(1, -108, 0, 60), COLORS.PanelSoft)
	audioButton.TextColor3 = COLORS.Text
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
end

function ShopController.start()
	buildGui()
	player:SetAttribute("PerfectJumpShopOpen", false)
	player:SetAttribute("PerfectJumpUiModal", false)

	player:GetAttributeChangedSignal("PerfectJumpShopOpen"):Connect(function()
		local open = player:GetAttribute("PerfectJumpShopOpen") == true
		setOpen(open)
		if open then
			requestProfile()
		end
	end)

	metaChanged.OnClientEvent:Connect(updateProfile)

	ContextActionService:BindActionAtPriority("PerfectJumpShop", function(_name, state)
		if state == Enum.UserInputState.Begin then
			local open = not (player:GetAttribute("PerfectJumpShopOpen") == true)
			setOpen(open)
			if open then
				requestProfile()
			end
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value + 60, Enum.KeyCode.ButtonY)

	requestProfile()
end

return ShopController
