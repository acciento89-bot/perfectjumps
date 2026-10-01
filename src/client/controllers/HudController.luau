--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GameConfig = require(shared.config.GameConfig)

local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundAction = remotes:WaitForChild("RoundAction") :: RemoteEvent
local roundState = remotes:WaitForChild("RoundState") :: RemoteEvent

local HudController = {}

local chargeStartedAt: number? = nil
local chargeFill: Frame
local scoreLabel: TextLabel
local comboLabel: TextLabel
local bestLabel: TextLabel
local phaseLabel: TextLabel
local resultPanel: Frame
local resultScore: TextLabel

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function stroke(parent: Instance, transparency: number)
	local item = Instance.new("UIStroke")
	item.Thickness = 1
	item.Transparency = transparency
	item.Color = Color3.fromRGB(255, 255, 255)
	item.Parent = parent
end

local function makeLabel(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(247, 249, 252)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
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
	gui.Parent = playerGui

	local topPanel = Instance.new("Frame")
	topPanel.Name = "Stats"
	topPanel.AnchorPoint = Vector2.new(0.5, 0)
	topPanel.Position = UDim2.fromScale(0.5, 0.035)
	topPanel.Size = UDim2.fromOffset(500, 76)
	topPanel.BackgroundColor3 = Color3.fromRGB(20, 24, 31)
	topPanel.BackgroundTransparency = 0.08
	topPanel.Parent = gui
	corner(topPanel, 18)
	stroke(topPanel, 0.75)

	scoreLabel = makeLabel(topPanel, "Score", "SCORE  0", UDim2.fromScale(0.32, 0.46), UDim2.fromScale(0.04, 0.08))
	comboLabel = makeLabel(topPanel, "Combo", "COMBO  0", UDim2.fromScale(0.30, 0.46), UDim2.fromScale(0.36, 0.08))
	bestLabel = makeLabel(topPanel, "Best", "BEST  0", UDim2.fromScale(0.28, 0.46), UDim2.fromScale(0.68, 0.08))
	phaseLabel = makeLabel(topPanel, "Phase", "READY", UDim2.fromScale(0.92, 0.28), UDim2.fromScale(0.04, 0.62))
	phaseLabel.TextColor3 = Color3.fromRGB(255, 184, 76)
	phaseLabel.TextScaled = false
	phaseLabel.TextSize = 14

	local chargePanel = Instance.new("Frame")
	chargePanel.Name = "Charge"
	chargePanel.AnchorPoint = Vector2.new(0.5, 1)
	chargePanel.Position = UDim2.fromScale(0.5, 0.94)
	chargePanel.Size = UDim2.fromOffset(420, 72)
	chargePanel.BackgroundColor3 = Color3.fromRGB(20, 24, 31)
	chargePanel.BackgroundTransparency = 0.08
	chargePanel.Parent = gui
	corner(chargePanel, 18)
	stroke(chargePanel, 0.75)

	local hint = makeLabel(
		chargePanel,
		"Hint",
		"HOLD  •  RELEASE",
		UDim2.fromScale(0.92, 0.34),
		UDim2.fromScale(0.04, 0.08)
	)
	hint.TextXAlignment = Enum.TextXAlignment.Center
	hint.TextColor3 = Color3.fromRGB(222, 227, 235)

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromScale(0.055, 0.56)
	track.Size = UDim2.fromScale(0.89, 0.22)
	track.BackgroundColor3 = Color3.fromRGB(47, 54, 66)
	track.Parent = chargePanel
	corner(track, 8)

	chargeFill = Instance.new("Frame")
	chargeFill.Name = "Fill"
	chargeFill.Size = UDim2.fromScale(0, 1)
	chargeFill.BackgroundColor3 = Color3.fromRGB(255, 169, 66)
	chargeFill.Parent = track
	corner(chargeFill, 8)

	resultPanel = Instance.new("Frame")
	resultPanel.Name = "Result"
	resultPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	resultPanel.Position = UDim2.fromScale(0.5, 0.5)
	resultPanel.Size = UDim2.fromOffset(420, 250)
	resultPanel.BackgroundColor3 = Color3.fromRGB(20, 24, 31)
	resultPanel.BackgroundTransparency = 0.03
	resultPanel.Visible = false
	resultPanel.Parent = gui
	corner(resultPanel, 24)
	stroke(resultPanel, 0.55)

	local title = makeLabel(
		resultPanel,
		"Title",
		"ROUND OVER",
		UDim2.fromScale(0.86, 0.18),
		UDim2.fromScale(0.07, 0.10)
	)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextColor3 = Color3.fromRGB(255, 184, 76)

	resultScore = makeLabel(
		resultPanel,
		"ResultScore",
		"SCORE  0",
		UDim2.fromScale(0.86, 0.16),
		UDim2.fromScale(0.07, 0.34)
	)
	resultScore.TextXAlignment = Enum.TextXAlignment.Center

	local retryButton = Instance.new("TextButton")
	retryButton.Name = "RetryButton"
	retryButton.AnchorPoint = Vector2.new(0.5, 1)
	retryButton.Position = UDim2.fromScale(0.5, 0.9)
	retryButton.Size = UDim2.fromScale(0.72, 0.23)
	retryButton.BackgroundColor3 = Color3.fromRGB(242, 151, 55)
	retryButton.TextColor3 = Color3.fromRGB(18, 21, 27)
	retryButton.Font = Enum.Font.GothamBold
	retryButton.Text = "RETRY"
	retryButton.TextScaled = true
	retryButton.AutoButtonColor = true
	retryButton.Selectable = true
	retryButton.Parent = resultPanel
	corner(retryButton, 15)

	retryButton.Activated:Connect(function()
		roundAction:FireServer("Retry")
	end)
end

local function refreshFromAttributes()
	local score = player:GetAttribute("PerfectJumpScore") or 0
	local combo = player:GetAttribute("PerfectJumpCombo") or 0
	local best = player:GetAttribute("PerfectJumpBestScore") or 0
	local phase = player:GetAttribute("PerfectJumpPhase") or "Ready"

	scoreLabel.Text = ("SCORE  %d"):format(score)
	comboLabel.Text = ("COMBO  %d"):format(combo)
	bestLabel.Text = ("BEST  %d"):format(best)
	phaseLabel.Text = string.upper(phase)
	resultPanel.Visible = phase == "GameOver"
	if resultPanel.Visible then
		resultScore.Text = ("SCORE  %d   •   BEST  %d"):format(score, best)
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

function HudController.start()
	buildGui()
	roundState.OnClientEvent:Connect(function(payload: any)
		if type(payload) == "table" and payload.Grade then
			phaseLabel.Text = string.upper(payload.Grade)
			phaseLabel.TextColor3 = if payload.Grade == "Perfect"
				then Color3.fromRGB(255, 208, 92)
				else Color3.fromRGB(226, 232, 242)
		end
		refreshFromAttributes()
	end)

	for _, attribute in {
		"PerfectJumpScore",
		"PerfectJumpCombo",
		"PerfectJumpBestScore",
		"PerfectJumpPhase",
	} do
		player:GetAttributeChangedSignal(attribute):Connect(refreshFromAttributes)
	end
	refreshFromAttributes()

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
end

return HudController
