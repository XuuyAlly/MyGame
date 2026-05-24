local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local CurrentWeapon = require(ReplicatedStorage.Source.Features.Weapon.UI.Screens.CurrentWeapon)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CurrentWeapon = e(CurrentWeapon),
	})
end
