local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)

local STUDIO_SIZE = Vector2.new(1500, 803)

--[[ ============================================================
     AutoScaledButton
     ============================================================
     A unified, auto-scaling button component for React-Luau.

     MODES (mutually exclusive — providing both is a runtime error):
       • Text button  → supply `Text` (and optionally text styling props)
       • Image button → supply `Image` (and optionally image styling props)

     AUTO-SCALE
       Mirrors the AutoScaledFrame approach: the button keeps a UDim2
       Size defined in studio units, then drives a child UIScale so it
       stays proportional across all resolutions.

     DEFAULTS
       Every visual and behavioural property has a sensible default so
       the component is usable with as little as:
           React.createElement(AutoScaledButton, { Size = UDim2.fromOffset(200, 60) })
     ============================================================ ]]

export type AutoScaledButtonProps = {
	-- ── Layout ──────────────────────────────────────────────────
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Rotation: number?,
	ZIndex: number?,
	LayoutOrder: number?,
	Visible: boolean?,
	ClipsDescendants: boolean?,

	-- ── Auto-scale ──────────────────────────────────────────────
	ScaleFactor: number?, -- multiplier on top of viewport scale (default 1)
	MinSize: Vector2?, -- minimum pixel size before scaling is clamped

	-- ── Appearance ──────────────────────────────────────────────
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,
	BorderSizePixel: number?,
	BorderColor3: Color3?,
	BorderMode: Enum.BorderMode?,

	-- ── Corner rounding (adds UICorner when set) ─────────────────
	CornerRadius: UDim?,

	-- ── Padding (adds UIPadding when any side is set) ────────────
	PaddingTop: UDim?,
	PaddingBottom: UDim?,
	PaddingLeft: UDim?,
	PaddingRight: UDim?,

	-- ── TEXT mode (mutually exclusive with Image) ────────────────
	Text: string?,
	Font: Enum.Font?,
	FontFace: Font?, -- alternative to Font for richer control
	TextSize: number?,
	TextColor3: Color3?,
	TextTransparency: number?,
	TextStrokeColor3: Color3?,
	TextStrokeTransparency: number?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	TextWrapped: boolean?,
	TextScaled: boolean?,
	TextTruncate: Enum.TextTruncate?,
	RichText: boolean?,
	MaxVisibleGraphemes: number?,
	LineHeight: number?,
	AutomaticSize: Enum.AutomaticSize?,

	-- ── IMAGE mode (mutually exclusive with Text) ────────────────
	Image: string?,
	ImageColor3: Color3?,
	ImageTransparency: number?,
	ImageRectOffset: Vector2?,
	ImageRectSize: Vector2?,
	ResampleMode: Enum.ResamplerMode?,
	ScaleType: Enum.ScaleType?,
	SliceCenter: Rect?,
	SliceScale: number?,
	TileSize: UDim2?,

	-- ── Hover / pressed images (ImageButton only) ────────────────
	HoverImage: string?,
	PressedImage: string?,

	-- ── Selection / focus ────────────────────────────────────────
	SelectionImageObject: GuiObject?,
	Selectable: boolean?,
	AutoButtonColor: boolean?,
	Modal: boolean?,
	Active: boolean?,

	-- ── Events ───────────────────────────────────────────────────
	OnActivated: ((rbx: GuiButton, inputObject: InputObject, clickCount: number) -> ())?,
	OnMouseButton1Click: ((rbx: GuiButton) -> ())?,
	OnMouseButton1Down: ((rbx: GuiButton, x: number, y: number) -> ())?,
	OnMouseButton1Up: ((rbx: GuiButton, x: number, y: number) -> ())?,
	OnMouseButton2Click: ((rbx: GuiButton) -> ())?,
	OnMouseButton2Down: ((rbx: GuiButton, x: number, y: number) -> ())?,
	OnMouseButton2Up: ((rbx: GuiButton, x: number, y: number) -> ())?,
	OnMouseEnter: ((rbx: GuiObject, x: number, y: number) -> ())?,
	OnMouseLeave: ((rbx: GuiObject, x: number, y: number) -> ())?,
	OnMouseMoved: ((rbx: GuiObject, x: number, y: number) -> ())?,
	OnMouseWheelForward: ((rbx: GuiObject, x: number, y: number) -> ())?,
	OnMouseWheelBackward: ((rbx: GuiObject, x: number, y: number) -> ())?,
	OnTouchTap: ((rbx: GuiObject, touchPositions: { Vector2 }) -> ())?,
	OnTouchLongPress: ((rbx: GuiObject, touchPositions: { Vector2 }, state: Enum.UserInputState) -> ())?,
	OnTouchPinch: ((
		rbx: GuiObject,
		touchPositions: { Vector2 },
		scale: number,
		velocity: number,
		state: Enum.UserInputState
	) -> ())?,
	OnTouchRotate: ((
		rbx: GuiObject,
		touchPositions: { Vector2 },
		rotation: number,
		velocity: number,
		state: Enum.UserInputState
	) -> ())?,
	OnTouchSwipe: ((rbx: GuiObject, swipeDirection: Enum.SwipeDirection, numberOfTouches: number) -> ())?,
	OnSelectionGained: ((rbx: GuiObject) -> ())?,
	OnSelectionLost: ((rbx: GuiObject) -> ())?,
	OnFocusLost: ((rbx: TextBox, enterPressed: boolean, inputThatCausedFocusLoss: InputObject) -> ())?,

	-- ── Children ─────────────────────────────────────────────────
	children: React.ReactNode?,
}

-- ── Internal helper: build the shared base props ──────────────────────────────
local function buildBaseProps(props: AutoScaledButtonProps, ref: React.Ref<any>): { [string]: any }
	return {
		Size = props.Size,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Rotation = props.Rotation or 0,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible ~= nil and props.Visible or true,
		ClipsDescendants = props.ClipsDescendants or false,

		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(60, 120, 220),
		BackgroundTransparency = props.BackgroundTransparency or 0,
		BorderSizePixel = props.BorderSizePixel or 0,
		BorderColor3 = props.BorderColor3,
		BorderMode = props.BorderMode,

		AutoButtonColor = props.AutoButtonColor ~= nil and props.AutoButtonColor or true,
		Active = props.Active ~= nil and props.Active or true,
		Selectable = props.Selectable ~= nil and props.Selectable or true,
		Modal = props.Modal or false,
		SelectionImageObject = props.SelectionImageObject,

		[React.Event.Activated] = props.OnActivated,
		[React.Event.MouseButton1Click] = props.OnMouseButton1Click,
		[React.Event.MouseButton1Down] = props.OnMouseButton1Down,
		[React.Event.MouseButton1Up] = props.OnMouseButton1Up,
		[React.Event.MouseButton2Click] = props.OnMouseButton2Click,
		[React.Event.MouseButton2Down] = props.OnMouseButton2Down,
		[React.Event.MouseButton2Up] = props.OnMouseButton2Up,
		[React.Event.MouseEnter] = props.OnMouseEnter,
		[React.Event.MouseLeave] = props.OnMouseLeave,
		[React.Event.MouseMoved] = props.OnMouseMoved,
		[React.Event.MouseWheelForward] = props.OnMouseWheelForward,
		[React.Event.MouseWheelBackward] = props.OnMouseWheelBackward,
		[React.Event.TouchTap] = props.OnTouchTap,
		[React.Event.TouchLongPress] = props.OnTouchLongPress,
		[React.Event.TouchPinch] = props.OnTouchPinch,
		[React.Event.TouchRotate] = props.OnTouchRotate,
		[React.Event.TouchSwipe] = props.OnTouchSwipe,
		[React.Event.SelectionGained] = props.OnSelectionGained,
		[React.Event.SelectionLost] = props.OnSelectionLost,

		ref = ref,
	}
end

-- ── Internal helper: shared decorative children (UIScale, UICorner, UIPadding) ─
local function buildDecorativeChildren(
	props: AutoScaledButtonProps,
	scaleBinding: React.Binding<number>
): { [string]: React.ReactNode }
	local children: { [string]: React.ReactNode } = {
		AutoScale = React.createElement("UIScale", {
			Scale = scaleBinding,
		}),
	}

	if props.CornerRadius then
		children.Corner = React.createElement("UICorner", {
			CornerRadius = props.CornerRadius,
		})
	end

	local hasPadding = props.PaddingTop or props.PaddingBottom or props.PaddingLeft or props.PaddingRight

	if hasPadding then
		children.Padding = React.createElement("UIPadding", {
			PaddingTop = props.PaddingTop,
			PaddingBottom = props.PaddingBottom,
			PaddingLeft = props.PaddingLeft,
			PaddingRight = props.PaddingRight,
		})
	end

	-- Merge caller-supplied children
	if props.children then
		if type(props.children) == "table" then
			for k, v in pairs(props.children :: any) do
				children[k] = v
			end
		else
			children.ExtraChild = props.children
		end
	end

	return children
end

-- ── Component ─────────────────────────────────────────────────────────────────
return React.forwardRef(function(props: AutoScaledButtonProps, ref: React.Ref<any>)
	-- ── Mutual exclusion guard ────────────────────────────────────────────────
	assert(
		not (props.Text ~= nil and props.Image ~= nil),
		"AutoScaledButton: Cannot supply both `Text` and `Image` at the same time. "
			.. "Use one or the other to select text-button or image-button mode."
	)

	-- ── Auto-scale logic (mirrors AutoScaledFrame) ────────────────────────────
	local screenSize = useViewportSize()
	local minSize = props.MinSize or Vector2.zero
	local scaleFactor = props.ScaleFactor or 1

	local scaleBinding, setScale = React.useBinding(scaleFactor)

	local minScale = React.useMemo(function()
		local sizeXOffset = props.Size.X.Offset
		local sizeYOffset = props.Size.Y.Offset
		if sizeXOffset == 0 or sizeYOffset == 0 then
			return 0
		end
		return math.max(minSize.X / sizeXOffset, minSize.Y / sizeYOffset)
	end, { screenSize, minSize, props.Size })

	React.useEffect(function()
		local newScale = scaleFactor * math.min(screenSize.X / STUDIO_SIZE.X, screenSize.Y / STUDIO_SIZE.Y)
		setScale(math.max(newScale, minScale))
	end, { screenSize, minSize, scaleFactor })

	-- ── Mode: Image button ────────────────────────────────────────────────────
	if props.Image ~= nil then
		local imageProps = buildBaseProps(props, ref)

		imageProps.Image = props.Image
		imageProps.ImageColor3 = props.ImageColor3
		imageProps.ImageTransparency = props.ImageTransparency or 0
		imageProps.ImageRectOffset = props.ImageRectOffset
		imageProps.ImageRectSize = props.ImageRectSize
		imageProps.ResampleMode = props.ResampleMode
		imageProps.ScaleType = props.ScaleType or Enum.ScaleType.Stretch
		imageProps.SliceCenter = props.SliceCenter
		imageProps.SliceScale = props.SliceScale
		imageProps.TileSize = props.TileSize
		imageProps.HoverImage = props.HoverImage
		imageProps.PressedImage = props.PressedImage

		return React.createElement("ImageButton", imageProps, buildDecorativeChildren(props, scaleBinding))
	end

	-- ── Mode: Text button (default) ───────────────────────────────────────────
	local textProps = buildBaseProps(props, ref)

	textProps.Text = props.Text or ""
	textProps.TextSize = props.TextSize or 18
	textProps.TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255)
	textProps.TextTransparency = props.TextTransparency or 0
	textProps.TextStrokeColor3 = props.TextStrokeColor3
	textProps.TextStrokeTransparency = props.TextStrokeTransparency
	textProps.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	textProps.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	textProps.TextWrapped = props.TextWrapped or false
	textProps.TextScaled = props.TextScaled or false
	textProps.TextTruncate = props.TextTruncate or Enum.TextTruncate.None
	textProps.RichText = props.RichText or false
	textProps.MaxVisibleGraphemes = props.MaxVisibleGraphemes
	textProps.LineHeight = props.LineHeight
	textProps.AutomaticSize = props.AutomaticSize

	if props.FontFace then
		textProps.FontFace = props.FontFace
	else
		textProps.Font = props.Font or Enum.Font.GothamBold
	end

	return React.createElement("TextButton", textProps, buildDecorativeChildren(props, scaleBinding))
end)
