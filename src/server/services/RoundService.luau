--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local GameConfig = require(shared.config.GameConfig)
local MonetizationConfig = require(shared.config.MonetizationConfig)
local JumpRules = require(shared.game.JumpRules)
local LaunchRules = require(shared.game.LaunchRules)
local RoundStateRules = require(shared.game.RoundStateRules)

local ProfileService = require(script.Parent.ProfileService)
local WorldService = require(script.Parent.WorldService)

local RoundService = {}

type Round = {
	Player: Player,
	Lane: WorldService.Lane,
	LaneIndex: number,
	Phase: RoundStateRules.Phase,
	ChargeStartedAt: number?,
	ActionToken: number,
	Score: number,
	Combo: number,
	Assisted: boolean,
	FailedAt: number?,
	RespawnCFrame: CFrame?,
	TargetConnection: RBXScriptConnection?,
	CharacterConnections: { RBXScriptConnection },
	RateWindowStartedAt: number,
	RateCount: number,
	RespawnGuard: boolean,
}

local remotes: Folder
local roundAction: RemoteEvent
local roundState: RemoteEvent
local getPlayerState: RemoteFunction

local rounds: { [Player]: Round } = {}
local nextLaneIndex = 0

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function getHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function statePayload(round: Round, extra: { [string]: any }?)
	local profile = ProfileService.GetSnapshot(round.Player)
	local payload = {
		Phase = round.Phase,
		Score = round.Score,
		Combo = round.Combo,
		Assisted = round.Assisted,
		BestScore = if profile then profile.BestScore else 0,
		HighestPlatform = if profile then profile.HighestPlatform else 0,
		Coins = if profile then profile.Coins else 0,
		Revives = if profile then profile.Inventory.Revives else 0,
		CurrentPlatformId = round.Lane.CurrentId,
		TargetPlatformId = round.Lane.TargetId,
		CurrentPosition = round.Lane.CurrentCollision.Position,
		TargetPosition = round.Lane.TargetCollision.Position,
		TargetWidth = round.Lane.TargetCollision.Size.X,
	}
	if extra then
		for key, value in extra do
			payload[key] = value
		end
	end
	return payload
end

local function syncAttributes(round: Round)
	local player = round.Player
	player:SetAttribute("PerfectJumpPhase", round.Phase)
	player:SetAttribute("PerfectJumpScore", round.Score)
	player:SetAttribute("PerfectJumpCombo", round.Combo)
	player:SetAttribute("PerfectJumpAssisted", round.Assisted)
	player:SetAttribute("PerfectJumpCurrentPlatform", round.Lane.CurrentId)
	player:SetAttribute("PerfectJumpTargetPlatform", round.Lane.TargetId)
end

local function emitState(round: Round, extra: { [string]: any }?)
	syncAttributes(round)
	roundState:FireClient(round.Player, statePayload(round, extra))
end

local function transition(round: Round, nextPhase: RoundStateRules.Phase): boolean
	if round.Phase == nextPhase then
		return true
	end
	if not RoundStateRules.CanTransition(round.Phase, nextPhase) then
		return false
	end
	round.Phase = nextPhase
	syncAttributes(round)
	return true
end

local function setGroundMovement(player: Player, enabled: boolean)
	local humanoid = getHumanoid(player)
	if not humanoid then
		return
	end
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.WalkSpeed = if enabled then GameConfig.Movement.PlatformWalkSpeed else GameConfig.Movement.AirWalkSpeed
	humanoid.AutoRotate = true
end

local function setNetworkOwner(root: BasePart, player: Player?)
	if not root:IsDescendantOf(Workspace) then
		return
	end
	local ok = pcall(function()
		root:SetNetworkOwner(player)
	end)
	if not ok and root:IsDescendantOf(Workspace) then
		pcall(function()
			root:SetNetworkOwnershipAuto()
		end)
	end
end

local function failRound(round: Round, reason: string)
	if round.Phase == "GameOver" then
		return
	end
	round.ChargeStartedAt = nil
	round.Phase = "GameOver"
	round.Combo = 0
	round.FailedAt = os.clock()
	round.ActionToken += 1
	setGroundMovement(round.Player, false)
	emitState(round, {
		Reason = reason,
	})
end

local function landingDistance(root: BasePart, target: BasePart): number
	local delta = root.Position - target.Position
	return Vector2.new(delta.X, delta.Z).Magnitude
end

local connectTarget: (Round) -> ()

local function handleLanding(round: Round)
	if round.Phase ~= "Airborne" then
		return
	end

	local root = getRoot(round.Player)
	if not root then
		return
	end
	if root.AssemblyLinearVelocity.Y > GameConfig.Movement.LandingVerticalSpeedLimit then
		return
	end

	local distance = landingDistance(root, round.Lane.TargetCollision)
	local perfectRadius = GameConfig.Landing.PerfectRadius
	if ProfileService.IsWidePerfectActive(round.Player) then
		perfectRadius *= MonetizationConfig.DeveloperProducts.WidePerfect5m.RadiusMultiplier
		round.Assisted = true
	end

	local grade = JumpRules.GradeLandingWithPerfectRadius(distance, round.Lane.TargetCollision.Size.X, perfectRadius)
	if grade == "Miss" then
		failRound(round, "Miss")
		return
	end

	if not transition(round, "Landed") then
		return
	end

	setNetworkOwner(root, round.Player)
	setGroundMovement(round.Player, true)

	local landedPlatformId = round.Lane.TargetId
	local nextCombo = JumpRules.NextCombo(round.Combo, grade)
	local scoreDelta = JumpRules.ScoreForLanding(grade, nextCombo)
	round.Combo = nextCombo
	round.Score += scoreDelta

	local reward = ProfileService.RecordLanding(
		round.Player,
		grade,
		round.Score,
		landedPlatformId,
		round.Combo,
		not round.Assisted
	)

	WorldService.advanceLane(round.Lane)
	connectTarget(round)

	emitState(round, {
		Grade = grade,
		ScoreDelta = scoreDelta,
		LandingDistance = distance,
		Reward = reward,
	})

	local token = round.ActionToken
	task.delay(0.12, function()
		if rounds[round.Player] ~= round or round.ActionToken ~= token or round.Phase ~= "Landed" then
			return
		end
		if transition(round, "Ready") then
			emitState(round)
		end
	end)
end

connectTarget = function(round: Round)
	if round.TargetConnection then
		round.TargetConnection:Disconnect()
	end

	local expectedTargetId = round.Lane.TargetId
	round.TargetConnection = round.Lane.TargetCollision.Touched:Connect(function(hit: BasePart)
		if round.Phase ~= "Airborne" or round.Lane.TargetId ~= expectedTargetId then
			return
		end
		local character = hit:FindFirstAncestorOfClass("Model")
		if character ~= round.Player.Character then
			return
		end
		handleLanding(round)
	end)
end

local function clearCharacterConnections(round: Round)
	for _, connection in round.CharacterConnections do
		connection:Disconnect()
	end
	table.clear(round.CharacterConnections)
end

local function prepareCharacter(round: Round, character: Model)
	clearCharacterConnections(round)
	round.ActionToken += 1
	round.ChargeStartedAt = nil

	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local root = character:WaitForChild("HumanoidRootPart") :: BasePart
	local spawnCFrame = round.RespawnCFrame or round.Lane.Spawn.CFrame
	round.RespawnCFrame = nil
	character:PivotTo(spawnCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	setNetworkOwner(root, round.Player)
	round.RespawnGuard = false

	if round.Phase == "GameOver" then
		setGroundMovement(round.Player, false)
	else
		round.Phase = "Ready"
		setGroundMovement(round.Player, true)
	end

	table.insert(
		round.CharacterConnections,
		humanoid.Died:Connect(function()
			failRound(round, "CharacterDied")
		end)
	)

	emitState(round)
end

local function rebuildLane(round: Round)
	if round.TargetConnection then
		round.TargetConnection:Disconnect()
		round.TargetConnection = nil
	end
	WorldService.destroyLane(round.Lane)
	round.Lane = WorldService.createLane(round.Player, round.LaneIndex)
	connectTarget(round)
end

local function retryRound(round: Round)
	if round.Phase ~= "GameOver" then
		return
	end
	if round.FailedAt and os.clock() - round.FailedAt < GameConfig.Failure.RetryDelaySeconds then
		return
	end

	round.ActionToken += 1
	round.Score = 0
	round.Combo = 0
	round.Assisted = false
	round.ChargeStartedAt = nil
	round.FailedAt = nil
	round.Phase = "Ready"
	round.RespawnCFrame = nil
	round.RespawnGuard = true
	-- Disconnect the old character listeners before LoadCharacter destroys the
	-- current humanoid. Otherwise the stale Died callback can fail the freshly
	-- reset round during the retry respawn.
	clearCharacterConnections(round)
	rebuildLane(round)
	round.Player.RespawnLocation = round.Lane.Spawn
	round.Player:LoadCharacter()
end

local function reviveRound(round: Round)
	if round.Phase ~= "GameOver" or not ProfileService.ConsumeRevive(round.Player) then
		return
	end
	round.ActionToken += 1
	round.Combo = 0
	round.Assisted = true
	round.ChargeStartedAt = nil
	round.FailedAt = nil
	round.Phase = "Ready"
	round.RespawnCFrame = round.Lane.CurrentCollision.CFrame + Vector3.new(0, 3.2, 0)
	round.RespawnGuard = true
	-- Revive uses the same character replacement path as retry. Remove stale
	-- Died listeners before replacing the character so the old humanoid cannot
	-- race the revived round back into GameOver.
	clearCharacterConnections(round)
	round.Player:LoadCharacter()
end

local function beginCharge(round: Round)
	if round.Phase ~= "Ready" then
		return
	end
	if not transition(round, "Charging") then
		return
	end
	round.ChargeStartedAt = os.clock()
	round.ActionToken += 1
	emitState(round, {
		ChargeStartedAt = round.ChargeStartedAt,
	})
end

local function cancelCharge(round: Round)
	if round.Phase ~= "Charging" then
		return
	end
	round.ChargeStartedAt = nil
	if transition(round, "Ready") then
		emitState(round)
	end
end

local function launchWithHeldSeconds(round: Round, heldSeconds: number): boolean
	if round.Phase ~= "Charging" then
		return false
	end

	round.ChargeStartedAt = nil
	if not LaunchRules.IsLegalChargeSeconds(heldSeconds) then
		cancelCharge(round)
		return false
	end

	local root = getRoot(round.Player)
	if not root then
		failRound(round, "MissingRoot")
		return false
	end

	local directionDelta = round.Lane.TargetCollision.Position - root.Position
	local horizontal = Vector3.new(directionDelta.X, 0, directionDelta.Z)
	if horizontal.Magnitude < 0.001 then
		cancelCharge(round)
		return false
	end

	if not transition(round, "Airborne") then
		return false
	end

	local normalized = JumpRules.NormalizeCharge(heldSeconds)
	local horizontalSpeed = LaunchRules.HorizontalSpeed(normalized)
	local verticalSpeed = LaunchRules.VerticalSpeed(normalized)
	local direction = horizontal.Unit

	if ProfileService.IsWidePerfectActive(round.Player) then
		round.Assisted = true
	end

	setGroundMovement(round.Player, false)
	setNetworkOwner(root, nil)
	root.AssemblyLinearVelocity =
		Vector3.new(direction.X * horizontalSpeed, verticalSpeed, direction.Z * horizontalSpeed)

	emitState(round, {
		ChargeSeconds = heldSeconds,
		ChargePower = normalized,
	})
	return true
end

local function releaseCharge(round: Round)
	if round.Phase ~= "Charging" or round.ChargeStartedAt == nil then
		return
	end

	local heldSeconds = os.clock() - round.ChargeStartedAt
	launchWithHeldSeconds(round, heldSeconds)
end

local function allowAction(round: Round): boolean
	local now = os.clock()
	if now - round.RateWindowStartedAt >= 1 then
		round.RateWindowStartedAt = now
		round.RateCount = 0
	end
	round.RateCount += 1
	return round.RateCount <= 12
end

local function onRoundAction(player: Player, action: any)
	local round = rounds[player]
	if not round or not allowAction(round) or type(action) ~= "string" then
		return
	end

	if action == "ChargeStart" then
		beginCharge(round)
	elseif action == "ChargeRelease" then
		releaseCharge(round)
	elseif action == "CancelCharge" then
		cancelCharge(round)
	elseif action == "Retry" then
		retryRound(round)
	elseif action == "UseRevive" then
		reviveRound(round)
	end
end

local function addPlayer(player: Player)
	local profile = ProfileService.WaitForProfile(player)
	if not profile or not player.Parent then
		return
	end

	nextLaneIndex += 1
	local lane = WorldService.createLane(player, nextLaneIndex)
	local round: Round = {
		Player = player,
		Lane = lane,
		LaneIndex = nextLaneIndex,
		Phase = "Ready",
		ChargeStartedAt = nil,
		ActionToken = 0,
		Score = 0,
		Combo = 0,
		Assisted = false,
		FailedAt = nil,
		RespawnCFrame = nil,
		TargetConnection = nil,
		CharacterConnections = {},
		RateWindowStartedAt = os.clock(),
		RateCount = 0,
		RespawnGuard = false,
	}
	rounds[player] = round
	player.RespawnLocation = lane.Spawn
	connectTarget(round)

	player.CharacterAdded:Connect(function(character)
		prepareCharacter(round, character)
	end)
	if player.Character then
		task.defer(prepareCharacter, round, player.Character)
	end
	syncAttributes(round)
end

local function removePlayer(player: Player)
	local round = rounds[player]
	if not round then
		return
	end
	clearCharacterConnections(round)
	if round.TargetConnection then
		round.TargetConnection:Disconnect()
	end
	WorldService.destroyLane(round.Lane)
	rounds[player] = nil
end

function RoundService.qaSnapshot(player: Player)
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	return if round then statePayload(round) else nil
end

function RoundService.qaLand(player: Player, centerDistance: number)
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	local root = getRoot(player)
	if not round or not root or round.Phase == "GameOver" then
		return false, nil
	end

	round.Phase = "Airborne"
	local target = round.Lane.TargetCollision
	local perfectRadius = GameConfig.Landing.PerfectRadius
	if ProfileService.IsWidePerfectActive(player) then
		perfectRadius *= MonetizationConfig.DeveloperProducts.WidePerfect5m.RadiusMultiplier
	end
	local grade = JumpRules.GradeLandingWithPerfectRadius(centerDistance, target.Size.X, perfectRadius)

	root.CFrame = CFrame.new(target.Position + Vector3.new(centerDistance, 3, 0))
	root.AssemblyLinearVelocity = Vector3.new(0, -2, 0)
	handleLanding(round)
	return round.Phase == "Landed" or round.Phase == "Ready", grade
end

function RoundService.qaLaunch(player: Player, heldSeconds: number)
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	local root = getRoot(player)
	if not round or not root or round.Phase == "GameOver" then
		return nil
	end

	root.CFrame = round.Lane.CurrentCollision.CFrame + Vector3.new(0, 3.2, 0)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	round.Phase = "Charging"
	round.ChargeStartedAt = os.clock()

	if not launchWithHeldSeconds(round, heldSeconds) then
		return nil
	end

	local velocity = root.AssemblyLinearVelocity
	local sample = {
		HeldSeconds = heldSeconds,
		ChargePower = JumpRules.NormalizeCharge(heldSeconds),
		HorizontalSpeed = Vector2.new(velocity.X, velocity.Z).Magnitude,
		VerticalSpeed = velocity.Y,
		Speed = velocity.Magnitude,
	}

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = round.Lane.CurrentCollision.CFrame + Vector3.new(0, 3.2, 0)
	round.ActionToken += 1
	round.Phase = "Ready"
	round.ChargeStartedAt = nil
	setNetworkOwner(root, player)
	setGroundMovement(player, true)
	emitState(round)

	return sample
end

function RoundService.qaFail(player: Player, reason: string?): boolean
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	if not round then
		return false
	end
	failRound(round, reason or "StudioQA")
	return round.Phase == "GameOver"
end

function RoundService.qaRetry(player: Player): boolean
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	if not round then
		return false
	end
	round.FailedAt = os.clock() - GameConfig.Failure.RetryDelaySeconds - 0.1
	retryRound(round)
	return round.Phase == "Ready"
end

function RoundService.qaRevive(player: Player): boolean
	assert(RunService:IsStudio(), "QA helpers are Studio-only")
	local round = rounds[player]
	if not round then
		return false
	end
	reviveRound(round)
	return round.Phase == "Ready" and round.Assisted == true
end

function RoundService.start()
	remotes = ReplicatedStorage:WaitForChild("PerfectJumpRemotes") :: Folder
	roundAction = remotes:WaitForChild("RoundAction") :: RemoteEvent
	roundState = remotes:WaitForChild("RoundState") :: RemoteEvent
	getPlayerState = remotes:WaitForChild("GetPlayerState") :: RemoteFunction

	roundAction.OnServerEvent:Connect(onRoundAction)
	getPlayerState.OnServerInvoke = function(player: Player)
		local round = rounds[player]
		if not round then
			return nil
		end
		return statePayload(round)
	end

	Players.PlayerAdded:Connect(function(player)
		task.spawn(addPlayer, player)
	end)
	Players.PlayerRemoving:Connect(removePlayer)
	for _, player in Players:GetPlayers() do
		task.spawn(addPlayer, player)
	end

	RunService.Heartbeat:Connect(function()
		for player, round in rounds do
			if round.Phase ~= "GameOver" and not round.RespawnGuard then
				local root = getRoot(player)
				if root then
					local current = round.Lane.CurrentCollision.Position
					local horizontalDistance =
						Vector2.new(root.Position.X - current.X, root.Position.Z - current.Z).Magnitude
					if root.Position.Y < math.max(GameConfig.Failure.KillPlaneY, current.Y - 24) then
						failRound(round, "Fall")
					elseif horizontalDistance > GameConfig.Failure.MaximumHorizontalDistanceFromLane then
						failRound(round, "OutOfBounds")
					end
				end
			end
		end
	end)
end

return RoundService
