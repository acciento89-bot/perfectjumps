--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
assert(player ~= nil, "LocalPlayer unavailable")

ReplicatedStorage:WaitForChild("PerfectJumpRemotes")

print(("[Perfect Jump] Client foundation initialized for %s"):format(player.Name))
