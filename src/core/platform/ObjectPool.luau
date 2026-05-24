local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataTemplate = require(ReplicatedStorage.Source.Game.DataTemplate)

local ObjectPool = {}
ObjectPool.__index = ObjectPool

local function NULLFUNC() end

export type ObjectPool = typeof(setmetatable(
	{} :: {
		_objects: { Instance },
		_object: Instance,
		_onGet: (object: Instance) -> (),
		_onFree: (object: Instance) -> (),
	},
	ObjectPool
))

function ObjectPool.new(data: DataTemplate.ObjectPoolData): ObjectPool
	local self = setmetatable({
		_objects = {},
		_object = data.object,
		_onGet = data.onGet or NULLFUNC,
		_onFree = data.onFree or NULLFUNC,
	}, ObjectPool)
	local onCreate = data.onCreate or NULLFUNC

	for i = 1, data.amount do
		local object = data.object:Clone()
		table.insert(self._objects, object)
		onCreate(object)
	end

	return self
end

function ObjectPool.get(self: ObjectPool)
	if #self._objects == 0 then
		return self._object:Clone()
	end

	local object = table.remove(self._objects, 1)
	self._onGet(object)
	return object
end

function ObjectPool.free(self: ObjectPool, object: Instance)
	self._onFree(object)
	table.insert(self._objects, object)
end

function ObjectPool.clear(self: ObjectPool)
	for _, object in ipairs(self._objects) do
		object:Destroy()
	end
	self._objects = {}
end

return ObjectPool
