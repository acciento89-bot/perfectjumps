--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage:WaitForChild("PerfectJumpRemotes")

local controllers = script:WaitForChild("controllers")
local CameraController = require(controllers.CameraController)
local HudController = require(controllers.HudController)
local InputController = require(controllers.InputController)

CameraController.start()
HudController.start()
InputController.start()

print("[Perfect Jump] Client gameplay initialized")
