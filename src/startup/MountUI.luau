local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUI = require(ReplicatedStorage.Source.Features.RootUI)
local e = React.createElement

local function MountUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local bin = Instance.new("ScreenGui")
	bin.Name = "Bin"
	bin.Parent = playerGui
	bin.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(bin)
	local app = e(RootUI)

	root:render(app)
end

return MountUI
