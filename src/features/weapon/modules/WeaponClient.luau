local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponTypes = require(ReplicatedStorage.Source.Features.Weapon.WeaponTypes)

local WeaponClient = {}
WeaponClient.__index = WeaponClient

type Weapon = WeaponTypes.WeaponConfig

local moduleTable = {
	BasicSword = ReplicatedStorage.Source.Features.Weapon.Modules.Classes.BasicSwordClient,
}

function WeaponClient.new(player: Player, name: string)
	local weaponModule = moduleTable[name]
	if not weaponModule then
		warn("Weapon " .. name .. " does not exist WATCH CASING")
		return
	end

	local trueModule = require(weaponModule)

	local weapon = trueModule.new(player)

	return weapon
end

return WeaponClient
