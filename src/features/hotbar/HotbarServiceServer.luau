local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ReplicatedStorage.Packages.DataService).server
local WeaponServiceServer = require(ServerScriptService.Features.Weapon.WeaponServiceServer)
local Networker = require(ReplicatedStorage.Packages.Networker)

local HotbarServiceServer = {}

function HotbarServiceServer.init(self: HotbarServiceServer)
	self.networker = Networker.server.new("HotbarService", self, {
		self.equipWeapon,
		self.unequipWeapon,
		self.swapSlots,
	})
end

function HotbarServiceServer.equipWeapon(_self: HotbarServiceServer, player: Player, slotNum: number)
	WeaponServiceServer:equipWeapon(player, slotNum)
end

function HotbarServiceServer.unequipWeapon(_self: HotbarServiceServer, player: Player, slotNum: number)
	WeaponServiceServer:unequipWeapon(player, slotNum)
end

function HotbarServiceServer.swapSlots(_self: HotbarServiceServer, player: Player, slot1: number, slot2: number)
	local slot1Key = "Slot" .. slot1
	local slot2Key = "Slot" .. slot2
	local slot1Data = DataService:get(player, { "hotbar", slot1Key })
	local slot2Data = DataService:get(player, { "hotbar", slot2Key })

	DataService:set(player, { "hotbar", slot1Key }, slot2Data)
	DataService:set(player, { "hotbar", slot2Key }, slot1Data)
end

type HotbarServiceServer = typeof(HotbarServiceServer) & {
	networker: Networker.Server,
}

return HotbarServiceServer :: HotbarServiceServer
