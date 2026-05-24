local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local MiscServiceClient = {}

function MiscServiceClient.init(self: MiscServiceClient)
	self.networker = Networker.client.new("MiscService", self)

	for _, floorPart in pairs(CollectionService:GetTagged("DiscoFloor")) do
		task.spawn(function()
			while true do
				task.wait(0.1)
				floorPart.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			end
		end)
	end
end

type MiscServiceClient = typeof(MiscServiceClient) & {
	networker: Networker.Client,
}

return MiscServiceClient :: MiscServiceClient
