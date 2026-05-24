local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WeaponTypes = require(ReplicatedStorage.Source.Features.Weapon.WeaponTypes)

type Weapon = WeaponTypes.WeaponConfig

local WeaponServer = {}
WeaponServer.__index = WeaponServer

local moduleTable = {
	BasicSword = ServerScriptService.Features.Weapon.Modules.Classes.BasicSwordServer,
}

function WeaponServer.new(player: Player, name: string)
	local weaponModule = moduleTable[name]
	if not weaponModule then
		warn("Weapon " .. name .. " does not exist WATCH CASING")
		return
	end
	local trueModule = require(weaponModule)

	local weapon = trueModule.new(player)

	return weapon
end

return WeaponServer
