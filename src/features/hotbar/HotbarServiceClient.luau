local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HotbarSlice = require(script.Parent.HotbarSlice)
local Networker = require(ReplicatedStorage.Packages.Networker)

local HotbarServiceClient = {}
local coreGuis = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.EmotesMenu,
}

function HotbarServiceClient.init(self: HotbarServiceClient)
	self.networker = Networker.client.new("HotbarService", self)

	for _, coreGui in pairs(coreGuis) do
		StarterGui:SetCoreGuiEnabled(coreGui, false)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local keyCode = input.KeyCode

		if keyCode.Value >= Enum.KeyCode.Zero.Value and keyCode.Value <= Enum.KeyCode.Nine.Value then
			local value = keyCode.Value - Enum.KeyCode.Zero.Value
			local currentSlot = HotbarSlice.state.selectedSlot()
			if value == 0 then
				warn("Slot 0 isn't a slot")
				return
			end
			HotbarSlice.state.selectedSlot(value)

			if currentSlot == value then
				self:unequipWeapon(value)
				HotbarSlice.state.selectedSlot(nil)
			else
				self:equipWeapon(value)
			end
		end
	end)
end

function HotbarServiceClient.equipWeapon(self: HotbarServiceClient, slotNum: number)
	self.networker:fire("equipWeapon", slotNum)
end

function HotbarServiceClient.unequipWeapon(self: HotbarServiceClient, slotNum: number)
	self.networker:fire("unequipWeapon", slotNum)
end

function HotbarServiceClient.swapSlots(self: HotbarServiceClient, slot1: number, slot2: number)
	self.networker:fire("swapSlots", slot1, slot2)
end

type HotbarServiceClient = typeof(HotbarServiceClient) & {
	networker: Networker.Client,
}

return HotbarServiceClient :: HotbarServiceClient
