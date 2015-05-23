
local WaveStation = {}
WaveStation.__index = WaveStation

function WaveStation.new(model)
  local self = {}

  self.Model = model

  return setmetatable(self, WaveStation)
end

function WaveStation:InRange(part, distance)
  local primaryPart = self.Model.PrimaryPart
  return (primaryPart.Position - part.Position).magnitude < distance
end

return WaveStation
