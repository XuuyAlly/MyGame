local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HotbarServiceServer = require(ServerScriptService.Features.Hotbar.HotbarServiceServer)
local MiscServiceServer = require(ServerScriptService.Features.Misc.MiscServiceServer)
local WeaponServiceServer = require(ServerScriptService.Features.Weapon.WeaponServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.DataTemplate)
local DataService = require(ReplicatedStorage.Packages.DataService).server

function DataService:onPlayerInit(player, _data)
	print("Player with name: " .. player.Name .. " has joined")
end

DataService:init({
	template = DataTemplate,
	dontSave = true,
	useMock = true,
})
WeaponServiceServer:init()
HotbarServiceServer:init()
MiscServiceServer:init()
