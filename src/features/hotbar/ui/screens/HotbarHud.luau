local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local Label = require(ReplicatedStorage.Source.Core.UI.Primitives.Label)
local HotbarRegistry = require(ReplicatedStorage.Source.Features.Hotbar.HotbarRegistry)
local HotbarServiceClient = require(ReplicatedStorage.Source.Features.Hotbar.HotbarServiceClient)
local HotbarSlice = require(ReplicatedStorage.Source.Features.Hotbar.HotbarSlice)
local e = React.createElement

type HotbarIconProps = {
	image: string?,
	index: number,
	selected: boolean,
}

local SLOT_COUNT = 9
local SLOT_SIZE = 100
local SLOT_GAP = 6
local CORNER = 8
local BAR_PADDING_X = 10
local BAR_PADDING_Y = 8

local function HotbarButton(props: HotbarIconProps)
	local hovered, setHovered = React.useState(false)

	return e(Button, {
		Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
		BackgroundColor3 = hovered and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.33,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = props.index,
		OnMouseEnter = function()
			setHovered(true)
		end,
		OnMouseLeave = function()
			setHovered(false)
		end,
		OnActivated = function()
			HotbarServiceClient:equipWeapon(props.index)
			print(DataService:get("hotbar"))
		end,
	}, {
		Corner = e("UICorner", { CornerRadius = UDim.new(0, CORNER) }),

		Stroke = e("UIStroke", {
			Color = props.selected and Color3.fromRGB(80, 190, 230) or Color3.fromRGB(60, 130, 160),
			Thickness = props.selected and 3 or 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),

		SlotNumber = e(Label, {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(4, 2),
			BackgroundTransparency = 1,
			Text = tostring(props.index),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 3,
		}),

		ItemImage = props.image and e("ImageLabel", {
			Size = UDim2.fromOffset(SLOT_SIZE - 16, SLOT_SIZE - 16),
			Position = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
			Image = props.image,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 2,
		}) or nil,
	})
end

local function buttons()
	local selectedSlot = ReactCharm.useAtom(HotbarSlice.state.selectedSlot)
	local data = useDataState("hotbar")

	local built = {}
	for i = 1, SLOT_COUNT do
		built["Slot_" .. i] = e(HotbarButton, {
			image = data["Slot" .. i] ~= "NULL" and HotbarRegistry[data["Slot" .. i].name] or nil,
			index = i,
			selected = selectedSlot ~= nil and selectedSlot == i,
		})
	end
	return built
end

local function Hotbar()
	local innerWidth = SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_GAP
	local barWidth = innerWidth + BAR_PADDING_X * 2
	local barHeight = SLOT_SIZE + BAR_PADDING_Y * 2

	return e("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -12),
		Size = UDim2.fromOffset(barWidth, barHeight),
		BorderSizePixel = 0,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, SLOT_GAP),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Buttons = e(buttons),
	})
end
return Hotbar
