local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local HotbarHud = require(ReplicatedStorage.Source.Features.Hotbar.UI.Screens.HotbarHud)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		Hotbar = e(HotbarHud),
	})
end
