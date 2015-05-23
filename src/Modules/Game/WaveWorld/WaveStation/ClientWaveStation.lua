
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local BaseModel = import("BaseModel")


--------------------------------------------------------------------------------
-- Client Wave Station
--------------------------------------------------------------------------------

local ClientWaveStation = {}
ClientWaveStation.__index = ClientWaveStation
setmetatable(ClientWaveStation, BaseModel)

function ClientWaveStation.new(model)
  local self = BaseModel.new(model)

  return setmetatable(self, ClientWaveStation)
end

return ClientWaveStation
