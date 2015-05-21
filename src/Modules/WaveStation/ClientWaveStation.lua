
local replicatedStorage = game:GetService("ReplicatedStorage")
local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))

local WaveStation = {}
WaveStation.__index = WaveStation

function WaveStation.new(model)
  local self = setmetatable({}, WaveStation)

  self.Model = model

  return self
end

function WaveStation:InRange(part, distance)
  local primaryPart = self.Model.PrimaryPart
  return (primaryPart.Position - part.Position).magnitude < distance
end

return WaveStation
