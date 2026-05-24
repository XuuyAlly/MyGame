local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Packages.DataService).client
local WeaponTypes = require(script.Parent.WeaponTypes)
local Networker = require(ReplicatedStorage.Packages.Networker)
local WeaponClient = require(ReplicatedStorage.Source.Features.Weapon.Modules.WeaponClient)

local WeaponServiceClient = {}
type Config = WeaponTypes.WeaponConfig

local player = Players.LocalPlayer

function WeaponServiceClient.init(self: WeaponServiceClient)
	self._registry = {}
	self.networker = Networker.client.new("WeaponService", self)

	WeaponClient.new(player, "BasicSword")
end

function WeaponServiceClient.register(self: WeaponServiceClient, config: Config)
	if self._registry[config.uniqueId] and config.uniqueId ~= "" then
		error("Weapon id already registered")
	end

	self.networker:getServerChangedSignal(config.name .. config.player.Name):Connect(function(uniqueId)
		config.uniqueId = uniqueId
		self._registry[config.uniqueId] = config
	end)
end

function WeaponServiceClient.isSlotEquipped(_self: WeaponServiceClient, slotNum: number)
	local slotKey = "Slot" .. slotNum
	local data = DataService:get({ "hotbar", slotKey })

	if data == "NULL" then
		print("Slot is empty at slot " .. slotNum)
		return false
	end

	if data.equipped then
		return true
	else
		return false
	end
end

function WeaponServiceClient.getWeapon(self: WeaponServiceClient, uniqueId: string)
	assert(self._registry[uniqueId], "Weapon with uniqueId " .. uniqueId .. " does not exist")
	return self._registry[uniqueId]
end

function WeaponServiceClient.BasicSwordPrint(self: WeaponServiceClient, uniqueId: string)
	self.networker:fire("BasicSwordPrint", uniqueId)
end

function WeaponServiceClient.equipWeapon(self: WeaponServiceClient, slotNum: number)
	self.networker:fire("equipWeapon", slotNum)
end

function WeaponServiceClient.unequipWeapon(self: WeaponServiceClient, slotNum: number)
	self.networker:fire("unequipWeapon", slotNum)
end

function WeaponServiceClient.getEquippedWeapon(self: WeaponServiceClient)
	local data = DataService:get("hotbar")

	for slotKey, slotValue in pairs(data) do
		if slotValue.equipped then
			local slotData = DataService:get({ "hotbar", slotKey })
			local equippedWeapon = self:getWeapon(slotData.uniqueId)
			return equippedWeapon
		end
	end

	return nil
end

function WeaponServiceClient.unregister(self: WeaponServiceClient, uniqueId: string)
	assert(self._registry[uniqueId], "Weapon with uniqueId " .. uniqueId .. " does not exist")
	self._registry[uniqueId] = nil
	self.networker:fire("unregister", uniqueId)
end

type WeaponServiceClient = typeof(WeaponServiceClient) & {
	networker: Networker.Client,
	_registry: { [string]: any },
}

return WeaponServiceClient :: WeaponServiceClient
