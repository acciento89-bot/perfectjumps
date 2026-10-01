--!strict

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes")
local roundAction = remotes:WaitForChild("RoundAction") :: RemoteEvent

local InputController = {}

local CHARGE_ACTION = "PerfectJumpCharge"
local RETRY_ACTION = "PerfectJumpRetry"
local ACTION_PRIORITY = Enum.ContextActionPriority.High.Value + 80

local charging = false

local function hideDefaultJumpButton()
	if not UserInputService.TouchEnabled then
		return
	end

	task.spawn(function()
		local touchGui = playerGui:WaitForChild("TouchGui", 10)
		if not touchGui then
			return
		end

		local function hide(instance: Instance)
			if instance.Name == "JumpButton" and instance:IsA("GuiObject") then
				instance.Visible = false
			end
		end

		for _, descendant in touchGui:GetDescendants() do
			hide(descendant)
		end
		touchGui.DescendantAdded:Connect(hide)
	end)
end

local function send(action: string)
	roundAction:FireServer(action)
end

local function chargeAction(_actionName: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		if not charging and player:GetAttribute("PerfectJumpPhase") == "Ready" then
			charging = true
			send("ChargeStart")
		end
	elseif inputState == Enum.UserInputState.End then
		if charging then
			charging = false
			send("ChargeRelease")
		end
	elseif inputState == Enum.UserInputState.Cancel then
		if charging then
			charging = false
			send("CancelCharge")
		end
	end
	return Enum.ContextActionResult.Sink
end

local function retryAction(_actionName: string, inputState: Enum.UserInputState): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin and player:GetAttribute("PerfectJumpPhase") == "GameOver" then
		send("Retry")
	end
	return Enum.ContextActionResult.Sink
end

local function refreshTouchButtons()
	local phase = player:GetAttribute("PerfectJumpPhase")
	local chargeButton = ContextActionService:GetButton(CHARGE_ACTION)
	if chargeButton then
		chargeButton.Visible = phase ~= "GameOver"
	end
	local retryButton = ContextActionService:GetButton(RETRY_ACTION)
	if retryButton then
		retryButton.Visible = phase == "GameOver"
	end
	if phase ~= "Charging" then
		charging = false
	end
end

function InputController.start()
	ContextActionService:BindActionAtPriority(
		CHARGE_ACTION,
		chargeAction,
		true,
		ACTION_PRIORITY,
		Enum.KeyCode.Space,
		Enum.UserInputType.MouseButton1,
		Enum.KeyCode.ButtonA
	)
	ContextActionService:SetTitle(CHARGE_ACTION, "HOLD")
	ContextActionService:SetPosition(CHARGE_ACTION, UDim2.fromScale(0.83, 0.78))

	ContextActionService:BindActionAtPriority(
		RETRY_ACTION,
		retryAction,
		true,
		ACTION_PRIORITY,
		Enum.KeyCode.R,
		Enum.KeyCode.ButtonX
	)
	ContextActionService:SetTitle(RETRY_ACTION, "RETRY")
	ContextActionService:SetPosition(RETRY_ACTION, UDim2.fromScale(0.83, 0.78))

	UserInputService.WindowFocusReleased:Connect(function()
		if charging then
			charging = false
			send("CancelCharge")
		end
	end)

	player.CharacterRemoving:Connect(function()
		if charging then
			charging = false
			send("CancelCharge")
		end
	end)

	player:GetAttributeChangedSignal("PerfectJumpPhase"):Connect(refreshTouchButtons)
	player.CharacterAdded:Connect(function()
		task.defer(hideDefaultJumpButton)
	end)
	task.defer(refreshTouchButtons)
	task.defer(hideDefaultJumpButton)
end

return InputController
