--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage:WaitForChild("PerfectJumpRemotes")

local controllers = script:WaitForChild("controllers")
local CameraController = require(controllers.CameraController)
local CosmeticPresentationController = require(controllers.CosmeticPresentationController)
local FeedbackController = require(controllers.FeedbackController)
local GraphicsQualityController = require(controllers.GraphicsQualityController)
local HudController = require(controllers.HudController)
local InputController = require(controllers.InputController)

CameraController.start()
CosmeticPresentationController.start()
FeedbackController.start()
GraphicsQualityController.start()
HudController.start()
InputController.start()

print("[Perfect Jump] Client gameplay initialized")
