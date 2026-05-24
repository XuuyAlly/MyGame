local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WeaponServiceServer = require(ServerScriptService.Features.Weapon.WeaponServiceServer)
local GenUniqueId = require(ReplicatedStorage.Source.Features.Weapon.Modules.GenUniqueId)
local WeaponRegistry = require(ReplicatedStorage.Source.Features.Weapon.WeaponRegistry)
local WeaponTypes = require(ReplicatedStorage.Source.Features.Weapon.WeaponTypes)

local BasicSwordServer = {}
BasicSwordServer.__index = BasicSwordServer

type BasicSword = WeaponTypes.WeaponConfig

function BasicSwordServer.new(player: Player)
	local self = setmetatable({
		name = "BasicSword",
		player = player,
		uniqueId = GenUniqueId(),
		weaponData = {},
	}, BasicSwordServer)

	self:init()
	WeaponServiceServer:register(self)

	return self
end

function BasicSwordServer.init(self: BasicSword)
	self.weaponData = {
		equipped = false,
		cooldowns = WeaponRegistry.BasicSword.Cooldowns,
		lastActivations = {
			print = 0,
		},
	}
end

function BasicSwordServer.canAbilityActivate(self: BasicSword, abilityName: string): boolean
	return self.weaponData.lastActivations[abilityName] + self.weaponData.cooldowns[abilityName] < time()
end

function BasicSwordServer.print(self: BasicSword)
	if self.weaponData.equipped == false then
		return
	end
	self.weaponData.lastActivations.print = time()
	print("Print ability from server for " .. self.player.Name)
end

return BasicSwordServer
