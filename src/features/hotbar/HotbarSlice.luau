local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>

local selectedSlot: Atom<number?> = atom(nil :: number?)

local actions = {}

return {
	state = {
		selectedSlot = selectedSlot,
	},
	actions = actions,
}
