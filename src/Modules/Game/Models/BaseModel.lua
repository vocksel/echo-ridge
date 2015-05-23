
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local Region = import("Region")

local function createRegionFromModel(model)
  -- GetModelCFrame is deprecated, but there does not seem to be an alternative.
  local position = model:GetModelCFrame()
  local size = model:GetExtentsSize()

  return Region.new(position, size)
end


--------------------------------------------------------------------------------
-- Base Model
--------------------------------------------------------------------------------

local BaseModel = {}
BaseModel.__index = BaseModel

function BaseModel.new(model)
  local self = {}

  assert(model.PrimaryPart, "The PrimaryPart property is required")

  self.Model = model
  self.PrimaryPart = model.PrimaryPart
  self.Region = createRegionFromModel(model)

  return setmetatable(self, BaseModel)
end

function BaseModel:__tostring()
  return self.Model.Name
end

function BaseModel:PartInRange(part, maxDistance)
  return (part.Position - self.PrimaryPart.Position).magnitude < maxDistance
end

function BaseModel:PartWithinBoundary(part)
  self.Region:CastPart(part)
end

return BaseModel
