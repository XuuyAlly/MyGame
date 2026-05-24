local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Label = require(ReplicatedStorage.Source.Core.UI.Primitives.Label)
local e = React.createElement

local function GetCurrentWeapon()
	local data = useDataState("hotbar")
	for _, slotValue in pairs(data) do
		if slotValue.equipped then
			return slotValue.name
		else
			return "No weapon equipped"
		end
	end

	return nil
end

local function CurrentWeapon()
	return e(Label, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.1),
		Size = UDim2.fromOffset(200, 60),
		Text = GetCurrentWeapon(),
	})
end

return CurrentWeapon
