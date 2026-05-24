local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)

local STUDIO_SIZE = Vector2.new(1500, 803)

--[[
	ScrollingFrame
 
	A component that wraps Roblox's ScrollingFrame instance, exposing all of its
	relevant properties with sensible defaults for every optional field.
 
	Pass `AutoScale = true` to enable viewport-relative scaling (identical to the
	Button component's behaviour).
 
	Props:
		-- Layout / Transform
		Size                    UDim2            Required. The size of the frame.
		Position                UDim2?           Optional. Position in parent.
		AnchorPoint             Vector2?         Optional. Anchor point for positioning.
		Rotation                number?          Optional. Rotation in degrees.
		ZIndex                  number?          Optional. Render order.
		LayoutOrder             number?          Optional. Order within a UIListLayout.
		ClipsDescendants        boolean?         Optional. Whether children outside bounds are hidden.
 
		-- Auto Scaling
		AutoScale               boolean?         Optional. When true, scales the frame relative to viewport size.
		ScaleFactor             number?          Optional. Multiplier applied on top of the viewport scale. Default 1.
		MinSize                 Vector2?         Optional. Minimum pixel size before scaling is clamped.
 
		-- Appearance
		BackgroundColor3        Color3?          Optional. Background fill colour.
		BackgroundTransparency  number?          Optional. 0 = opaque, 1 = invisible.
		BorderSizePixel         number?          Optional. Legacy border width (0 to disable).
		BorderColor3            Color3?          Optional. Legacy border colour.
 
		-- Scrolling behaviour
		ScrollingEnabled        boolean?         Optional. Whether the user can scroll at all.
		ScrollingDirection      Enum.ScrollingDirection? Optional. Axis(es) the user can scroll along.
		ElasticBehavior         Enum.ElasticBehavior?    Optional. Bounce-back behaviour at the edges.
		ScrollBarThickness      number?          Optional. Pixel width of the scroll bars.
		ScrollBarImageColor3    Color3?          Optional. Tint applied to the scroll-bar image.
		ScrollBarImageTransparency number?       Optional. Transparency of the scroll-bar image.
		TopImage                string?          Optional. Asset ID for the top scroll-bar cap.
		MidImage                string?          Optional. Asset ID for the scroll-bar track.
		BottomImage             string?          Optional. Asset ID for the bottom scroll-bar cap.
		HorizontalScrollBarInset Enum.ScrollBarInset? Optional. Inset behaviour for the horizontal bar.
		VerticalScrollBarInset  Enum.ScrollBarInset?  Optional. Inset behaviour for the vertical bar.
		VerticalScrollBarPosition Enum.VerticalScrollBarPosition? Optional. Left or right side.
 
		-- Canvas
		CanvasSize              UDim2?           Optional. Total scrollable content area.
		CanvasPosition          Vector2?         Optional. Current scroll offset in pixels.
		AutomaticCanvasSize     Enum.AutomaticSize? Optional. Auto-expands canvas to fit children.
 
		-- Events
		OnScrollingFrameChanged (((rbx: ScrollingFrame) -> ()))?
		                                         Fired when CanvasPosition changes (property changed).
 
		-- Children
		children                React.ReactNode? Optional child elements (e.g. UIListLayout, UIPadding).
]]

export type ScrollingFrameProps = {
	-- Layout / Transform
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Rotation: number?,
	ZIndex: number?,
	LayoutOrder: number?,
	ClipsDescendants: boolean?,

	-- Auto Scaling
	AutoScale: boolean?,
	ScaleFactor: number?,
	MinSize: Vector2?,

	-- Appearance
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	BorderSizePixel: number?,
	BorderColor3: Color3?,

	-- Scrolling behaviour
	ScrollingEnabled: boolean?,
	ScrollingDirection: Enum.ScrollingDirection?,
	ElasticBehavior: Enum.ElasticBehavior?,
	ScrollBarThickness: number?,
	ScrollBarImageColor3: Color3?,
	ScrollBarImageTransparency: number?,
	TopImage: string?,
	MidImage: string?,
	BottomImage: string?,
	HorizontalScrollBarInset: Enum.ScrollBarInset?,
	VerticalScrollBarInset: Enum.ScrollBarInset?,
	VerticalScrollBarPosition: Enum.VerticalScrollBarPosition?,

	-- Canvas
	CanvasSize: UDim2?,
	CanvasPosition: Vector2?,
	AutomaticCanvasSize: Enum.AutomaticSize?,

	-- Events
	OnScrollingFrameChanged: ((rbx: ScrollingFrame) -> ())?,

	-- Children
	children: React.ReactNode?,
}

local DEFAULTS = {
	-- Layout / Transform
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.new(0, 0),
	Rotation = 0,
	ZIndex = 1,
	LayoutOrder = 0,
	ClipsDescendants = true,

	-- Appearance
	BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	BorderColor3 = Color3.fromRGB(0, 0, 0),

	-- Scrolling behaviour
	ScrollingEnabled = true,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	ScrollBarThickness = 6,
	ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
	ScrollBarImageTransparency = 0,
	TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
	MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
	BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
	HorizontalScrollBarInset = Enum.ScrollBarInset.None,
	VerticalScrollBarInset = Enum.ScrollBarInset.None,
	VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,

	-- Canvas
	CanvasSize = UDim2.fromScale(0, 0),
	CanvasPosition = Vector2.zero,
	AutomaticCanvasSize = Enum.AutomaticSize.None,
}

-- Computes and tracks a UIScale value identical to AutoScaledFrame / Button logic.
-- Always called (Rules of Hooks); short-circuits to a scale of 1 when autoScale is false.
local function useScrollingFrameScale(autoScale: boolean, scaleFactor: number, minSize: Vector2, size: UDim2)
	local screenSize = useViewportSize()
	local scaleBinding, setScale = React.useBinding(scaleFactor)

	local minScale = React.useMemo(function()
		if not autoScale or (minSize.X == 0 and minSize.Y == 0) then
			return 0
		end
		local minX = if size.X.Offset > 0 then minSize.X / size.X.Offset else 0
		local minY = if size.Y.Offset > 0 then minSize.Y / size.Y.Offset else 0
		return math.max(minX, minY)
	end, { autoScale, screenSize, minSize, size })

	React.useEffect(function()
		if not autoScale then
			setScale(1)
			return
		end
		local newScale = scaleFactor * math.min(screenSize.X / STUDIO_SIZE.X, screenSize.Y / STUDIO_SIZE.Y)
		setScale(math.max(newScale, minScale))
	end, { autoScale, screenSize, minSize, scaleFactor, minScale })

	return scaleBinding
end

return React.forwardRef(function(props: ScrollingFrameProps, ref: React.Ref<any>)
	-- Layout / Transform
	local size = if props.Size ~= nil then props.Size else DEFAULTS.Size
	local position = if props.Position ~= nil then props.Position else DEFAULTS.Position
	local anchorPoint = if props.AnchorPoint ~= nil then props.AnchorPoint else DEFAULTS.AnchorPoint
	local rotation = if props.Rotation ~= nil then props.Rotation else DEFAULTS.Rotation
	local zIndex = if props.ZIndex ~= nil then props.ZIndex else DEFAULTS.ZIndex
	local layoutOrder = if props.LayoutOrder ~= nil then props.LayoutOrder else DEFAULTS.LayoutOrder
	local clipsDescendants = if props.ClipsDescendants ~= nil then props.ClipsDescendants else DEFAULTS.ClipsDescendants

	-- Auto Scaling
	local autoScale = props.AutoScale == true
	local scaleFactor = if props.ScaleFactor ~= nil then props.ScaleFactor else 1
	local minSize = props.MinSize or Vector2.zero

	-- Always call the hook (Rules of Hooks); it short-circuits internally when autoScale is false.
	local scaleBinding = useScrollingFrameScale(autoScale, scaleFactor, minSize, size)

	-- Appearance
	local bgColor = if props.BackgroundColor3 ~= nil then props.BackgroundColor3 else DEFAULTS.BackgroundColor3
	local bgTransparency = if props.BackgroundTransparency ~= nil
		then props.BackgroundTransparency
		else DEFAULTS.BackgroundTransparency
	local borderSize = if props.BorderSizePixel ~= nil then props.BorderSizePixel else DEFAULTS.BorderSizePixel
	local borderColor = if props.BorderColor3 ~= nil then props.BorderColor3 else DEFAULTS.BorderColor3

	-- Scrolling behaviour
	local scrollingEnabled = if props.ScrollingEnabled ~= nil then props.ScrollingEnabled else DEFAULTS.ScrollingEnabled
	local scrollingDirection = if props.ScrollingDirection ~= nil
		then props.ScrollingDirection
		else DEFAULTS.ScrollingDirection
	local elasticBehavior = if props.ElasticBehavior ~= nil then props.ElasticBehavior else DEFAULTS.ElasticBehavior
	local scrollBarThickness = if props.ScrollBarThickness ~= nil
		then props.ScrollBarThickness
		else DEFAULTS.ScrollBarThickness
	local scrollBarImageColor = if props.ScrollBarImageColor3 ~= nil
		then props.ScrollBarImageColor3
		else DEFAULTS.ScrollBarImageColor3
	local scrollBarImageTransparency = if props.ScrollBarImageTransparency ~= nil
		then props.ScrollBarImageTransparency
		else DEFAULTS.ScrollBarImageTransparency
	local topImage = if props.TopImage ~= nil then props.TopImage else DEFAULTS.TopImage
	local midImage = if props.MidImage ~= nil then props.MidImage else DEFAULTS.MidImage
	local bottomImage = if props.BottomImage ~= nil then props.BottomImage else DEFAULTS.BottomImage
	local horizontalInset = if props.HorizontalScrollBarInset ~= nil
		then props.HorizontalScrollBarInset
		else DEFAULTS.HorizontalScrollBarInset
	local verticalInset = if props.VerticalScrollBarInset ~= nil
		then props.VerticalScrollBarInset
		else DEFAULTS.VerticalScrollBarInset
	local verticalBarPosition = if props.VerticalScrollBarPosition ~= nil
		then props.VerticalScrollBarPosition
		else DEFAULTS.VerticalScrollBarPosition

	-- Canvas
	local canvasSize = if props.CanvasSize ~= nil then props.CanvasSize else DEFAULTS.CanvasSize
	local canvasPosition = if props.CanvasPosition ~= nil then props.CanvasPosition else DEFAULTS.CanvasPosition
	local automaticCanvasSize = if props.AutomaticCanvasSize ~= nil
		then props.AutomaticCanvasSize
		else DEFAULTS.AutomaticCanvasSize

	-- Builds the UIScale child merged with any caller-supplied children.
	-- Only injects UIScale when AutoScale is true; otherwise children pass through untouched.
	local function buildChildren(callerChildren: React.ReactNode?): { [any]: any }?
		if not autoScale then
			return callerChildren :: any
		end

		local childTable: { [any]: any } = {
			__UIScale = React.createElement("UIScale", { Scale = scaleBinding }),
		}

		if type(callerChildren) == "table" then
			for k, v in callerChildren :: { [any]: any } do
				childTable[k] = v
			end
		elseif callerChildren ~= nil then
			childTable.__child = callerChildren
		end

		return childTable
	end

	return React.createElement("ScrollingFrame", {
		-- Layout / Transform
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		Rotation = rotation,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
		ClipsDescendants = clipsDescendants,

		-- Appearance
		BackgroundColor3 = bgColor,
		BackgroundTransparency = bgTransparency,
		BorderSizePixel = borderSize,
		BorderColor3 = borderColor,

		-- Scrolling behaviour
		ScrollingEnabled = scrollingEnabled,
		ScrollingDirection = scrollingDirection,
		ElasticBehavior = elasticBehavior,
		ScrollBarThickness = scrollBarThickness,
		ScrollBarImageColor3 = scrollBarImageColor,
		ScrollBarImageTransparency = scrollBarImageTransparency,
		TopImage = topImage,
		MidImage = midImage,
		BottomImage = bottomImage,
		HorizontalScrollBarInset = horizontalInset,
		VerticalScrollBarInset = verticalInset,
		VerticalScrollBarPosition = verticalBarPosition,

		-- Canvas
		CanvasSize = canvasSize,
		CanvasPosition = canvasPosition,
		AutomaticCanvasSize = automaticCanvasSize,

		ref = ref,

		[React.Change.CanvasPosition] = props.OnScrollingFrameChanged,
	}, buildChildren(props.children))
end)
