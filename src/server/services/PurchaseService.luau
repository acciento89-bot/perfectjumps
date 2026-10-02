--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local MonetizationConfig = require(shared.config.MonetizationConfig)
local ReceiptRules = require(shared.game.ReceiptRules)
local ProfileService = require(script.Parent.ProfileService)

local PurchaseService = {}

local productsById: { [number]: string } = {}
for productName, definition in MonetizationConfig.DeveloperProducts do
	if definition.ProductId > 0 then
		productsById[definition.ProductId] = productName
	end
end

local function refreshPass(player: Player)
	local pass = MonetizationConfig.GamePasses.PremiumThemes
	if pass.GamePassId <= 0 then
		player:SetAttribute("PerfectJumpPremiumThemes", false)
		return
	end
	local ok, owned =
		pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, pass.GamePassId)
	player:SetAttribute("PerfectJumpPremiumThemes", ok and owned == true)
end

function PurchaseService.start()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local productName = productsById[receiptInfo.ProductId]
		if not productName then
			warn(("[Perfect Jump] unknown developer product id %d"):format(receiptInfo.ProductId))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local purchaseKey = ReceiptRules.key(receiptInfo.PurchaseId)
		if ProfileService.ProcessReceipt(player, purchaseKey, productName) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	Players.PlayerAdded:Connect(function(player)
		task.spawn(refreshPass, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(refreshPass, player)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if purchased and passId == MonetizationConfig.GamePasses.PremiumThemes.GamePassId then
			player:SetAttribute("PerfectJumpPremiumThemes", true)
		end
	end)
end

return PurchaseService
