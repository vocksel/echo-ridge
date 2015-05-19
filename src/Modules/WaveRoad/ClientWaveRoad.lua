
local ClientWaveRoad = {}
ClientWaveRoad.__index = ClientWaveRoad

local replicatedStorage = game:GetService("ReplicatedStorage")
local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local Region = import("Region")

local function createRegionFromModel(model, padding)
  -- This method is deprecated, but there does not seem to be an alternative.
  local pos = model:GetModelCFrame()
  local size = model:GetExtentsSize()

  return Region.new(pos, size+padding)
end

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

function ClientWaveRoad:InsideBoundary(part)
  -- Padding to add around the region to make it bigger than the actual model.
  --
  -- This is set arbitrarily. The top of the Wave Road must extend much
  -- farther than a player would normally be able to reach by jumping. This
  -- is because gear is allowed. Players can make use of the Gravity Coil and
  -- jump very high.
  --
  -- When the player is outside of the boundary the Wave Road disappears.
  -- This should only happen if a player travels a greate distance upwards,
  -- so people can still have fun with the Gravity Coil without having the
  -- Wave Road disappear from under them.
  local padding = Vector3.new(0, 24, 0)
  local region = createRegionFromModel(self.Model, padding)
  return region:CastPart(part)
end

return ClientWaveRoad
