--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("PerfectJump"):WaitForChild("Shared")
local RemoteDefinitions = require(shared.remotes.RemoteDefinitions)

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

print("[Perfect Jump] Server foundation initialized")
