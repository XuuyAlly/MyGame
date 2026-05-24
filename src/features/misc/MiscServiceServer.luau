local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local MiscServiceServer = {}

function MiscServiceServer.init(self: MiscServiceServer)
	self.networker = Networker.server.new("MiscService", self, {})
end

type MiscServiceServer = typeof(MiscServiceServer) & {
	networker: Networker.Server,
}

return MiscServiceServer :: MiscServiceServer
