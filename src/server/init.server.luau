--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local RemoteDefinitions = require(shared.remotes.RemoteDefinitions)

local existingRemotes = ReplicatedStorage:FindFirstChild("PerfectJumpRemotes")
if existingRemotes then
	existingRemotes:Destroy()
end

local remotes = Instance.new("Folder")
remotes.Name = "PerfectJumpRemotes"
remotes.Parent = ReplicatedStorage

for _, definition in RemoteDefinitions do
	local instance
	if definition.Kind == "Event" then
		instance = Instance.new("RemoteEvent")
	else
		instance = Instance.new("RemoteFunction")
	end
	instance.Name = definition.Name
	instance.Parent = remotes
end

local WorldService = require(script.services.WorldService)
local RoundService = require(script.services.RoundService)

WorldService.start()
RoundService.start()

print("[Perfect Jump] Server gameplay initialized")
