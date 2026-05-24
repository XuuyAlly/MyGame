local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>

local BillboardModels: Atom<{ [Instance]: any }> = atom({})

local actions = {
	addModel = function(instance: Instance, data: any)
		BillboardModels(function(prev)
			return Sift.Dictionary.set(prev, instance, data)
		end)
	end,

	removeModel = function(instance: Instance)
		BillboardModels(function(prev)
			return Sift.Dictionary.removeKey(prev, instance)
		end)
	end,
}

return {
	state = {
		models = BillboardModels,
	},
	actions = actions,
}
