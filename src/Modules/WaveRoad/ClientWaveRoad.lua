
local ClientWaveRoad = {}
ClientWaveRoad.__index = ClientWaveRoad

function ClientWaveRoad.new(model)
  local self = setmetatable({}, ClientWaveRoad)

  self.Model = model

  -- Keep the original parent in memory so that the Wave Road can be moved back
  -- later (Thus hiding it from view).
  self.OrigParent = model.Parent

  return self
end

function ClientWaveRoad:Show()
  self.Model.Parent = workspace
end

function ClientWaveRoad:Hide()
  self.Model.Parent = self.OrigParent
end

return ClientWaveRoad
