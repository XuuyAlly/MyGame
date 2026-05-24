local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local DataService = require(ReplicatedStorage.Packages.DataService).client
local WeaponServiceClient = require(ReplicatedStorage.Source.Features.Weapon.WeaponServiceClient)
local WeaponTypes = require(ReplicatedStorage.Source.Features.Weapon.WeaponTypes)

local BasicSwordClient = {}
BasicSwordClient.__index = BasicSwordClient

type BasicSword = WeaponTypes.WeaponConfig

function BasicSwordClient.new(player: Player)
	local self = setmetatable({
		name = "BasicSword",
		player = player,
		uniqueId = "",
		weaponData = {},
	}, BasicSwordClient)

	WeaponServiceClient:register(self)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.F then
			WeaponServiceClient:BasicSwordPrint(self.uniqueId)
			self:print()
		end
	end)

	return self
end

function BasicSwordClient.print(self: BasicSword)
	local data = DataService:get({ "hotbar", "Slot1" })
	if data.equipped == false or data == "NULL" then
		return
	end
	print("Client print ability for " .. self.player.Name)
end

return BasicSwordClient
