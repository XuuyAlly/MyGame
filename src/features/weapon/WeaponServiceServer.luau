local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ReplicatedStorage.Packages.DataService).server
local WeaponServer = require(ServerScriptService.Features.Weapon.Modules.WeaponServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local WeaponTypes = require(ReplicatedStorage.Source.Features.Weapon.WeaponTypes)

local WeaponServiceServer = {}
type Config = WeaponTypes.WeaponConfig

--[[
	Weapon data should include equipped, lastActivations, cooldowns, 
]]

function WeaponServiceServer.init(self: WeaponServiceServer)
	self._registry = {}
	self.networker = Networker.server.new("WeaponService", self, {
		self.unregister,
		self.equipWeapon,
		self.unequipWeapon,
		self.BasicSwordPrint,
	})

	Players.PlayerAdded:Connect(function(player)
		self:playerAdded(player)
	end)
end

function WeaponServiceServer.playerAdded(_self: WeaponServiceServer, player: Player)
	WeaponServer.new(player, "BasicSword")
end

function WeaponServiceServer.register(self: WeaponServiceServer, config: Config)
	if self._registry[config.uniqueId] then
		error("Weapon id already registered")
	end
	self._registry[config.uniqueId] = config
	self.networker:set(config.player, config.name .. config.player.Name, config.uniqueId)

	local dataForClient = {
		name = config.name,
		player = config.player,
		uniqueId = config.uniqueId,
		equipped = config.weaponData.equipped,
	}

	DataService:waitForData(config.player)
	local data = DataService:get(config.player, "hotbar")

	for slotKey, slotValue in pairs(data) do
		if slotValue == "NULL" then
			DataService:set(config.player, { "hotbar", slotKey }, dataForClient)
			break
		end
	end

	print(DataService:get(config.player, "hotbar"))
end

function WeaponServiceServer.BasicSwordPrint(self: WeaponServiceServer, _player: Player, uniqueId: string)
	local sword = self:getWeapon(uniqueId)
	if sword.name ~= "BasicSword" then
		warn("Weapon is not a BasicSword")
		return
	end

	sword:print()
end

function WeaponServiceServer.equipWeapon(self: WeaponServiceServer, player: Player, slotNum: number)
	local key = "Slot" .. slotNum
	local data = DataService:get(player, { "hotbar", key })
	local hotbar = DataService:get(player, "hotbar")

	if slotNum == 0 then
		warn("Slot 0 isn't a slot")
		return
	end

	if data == "NULL" then
		print("Slot is empty at slot " .. slotNum)
		--also un-equip all other weapons for slot switching
		for slotKey, slotValue in pairs(hotbar) do
			if slotValue == "NULL" then
				continue
			end

			if slotValue.equipped then
				DataService:set(player, { "hotbar", slotKey, "equipped" }, false)
			end
		end
		return
	end

	-- Un-equip all other weapons for extra safety from exploiters
	for slotKey, slotValue in pairs(hotbar) do
		if slotValue == "NULL" then
			continue
		end

		if slotValue.equipped then
			DataService:set(player, { "hotbar", slotKey, "equipped" }, false)
		end
	end

	DataService:set(player, { "hotbar", key, "equipped" }, true)
	local weapon = self:getWeapon(data.uniqueId)
	weapon.weaponData.equipped = true
end

function WeaponServiceServer.unequipWeapon(self: WeaponServiceServer, player: Player, slotNum: number)
	local key = "Slot" .. slotNum
	local data = DataService:get(player, { "hotbar", key })

	if data.equipped == false then
		print("Weapon is already unequipped")
		return
	end

	if slotNum == 0 then
		warn("Slot 0 isn't a slot")
		return
	end

	if data == "NULL" then
		print("Slot is empty at slot " .. slotNum)
		return
	end

	DataService:set(player, { "hotbar", key, "equipped" }, false)

	local weapon = self:getWeapon(data.uniqueId)
	weapon.weaponData.equipped = false
end

function WeaponServiceServer.getWeapon(self: WeaponServiceServer, uniqueId: string)
	assert(self._registry[uniqueId], "Weapon with uniqueId " .. uniqueId .. " does not exist")
	return self._registry[uniqueId]
end

function WeaponServiceServer.unregister(self: WeaponServiceServer, _player: Player, uniqueId: string)
	assert(self._registry[uniqueId], "Weapon with uniqueId " .. uniqueId .. " does not exist")
	local weapon = self:getWeapon(uniqueId)

	local playerData = DataService:get(weapon.player, "hotbar")
	DataService:waitForData(weapon.player)

	for slotKey, slotValue in pairs(playerData) do
		if slotValue.uniqueId == uniqueId then
			DataService:set(weapon.player, { "hotbar", slotKey }, "NULL")
		end
	end

	self._registry[uniqueId] = nil
end

type WeaponServiceServer = typeof(WeaponServiceServer) & {
	networker: Networker.Server,
	_registry: { [string]: Config },
}

return WeaponServiceServer :: WeaponServiceServer
