local replicatedStorage = game:GetService("ReplicatedStorage")

local Region = require(replicatedStorage.Region)

local function getMaxPlayerHeight()
  local playerHeight = 4
  local jumpHeight = 8
  return playerHeight + jumpHeight
end

local function getDimensions(model)
  -- GetModelCFrame is deprecated, but there does not seem to be an alternative.
  --
  -- We're getting the position to pass off to the Region constructor. It only
  -- Accepts Vector3s.
  local position = model:GetModelCFrame().p
  local size = model:GetExtentsSize()

  return position, size
end

local function adjustForPadding(position, size, padding)
  local paddedPosition = position + Vector3.new(0, padding/2, 0)
  local paddedSize = size + Vector3.new(0, padding, 0)

  return paddedPosition, paddedSize
end

local function createRegion(model, padding)
  local position, size = getDimensions(model)

  if padding then
    position, size = adjustForPadding(position, size, padding)
  end

  return Region.new(position, size)
end

--------------------------------------------------------------------------------
-- Base Model
--------------------------------------------------------------------------------

local BaseModel = {}
BaseModel.__index = BaseModel

function BaseModel.new(model)
  assert(model.PrimaryPart, "The PrimaryPart property is required")

  local self = {}
  local padding = getMaxPlayerHeight()

  self.Model = model
  self.PrimaryPart = model.PrimaryPart
  self.Region = createRegion(model, padding)

  return setmetatable(self, BaseModel)
end

function BaseModel:__tostring()
  return self.Model.Name
end

function BaseModel:PartInRange(part, maxDistance)
  return (part.Position - self.PrimaryPart.Position).magnitude < maxDistance
end

function BaseModel:PartWithinBoundary(part)
  return self.Region:PartIsInRegion(part)
end

function BaseModel:PlayerWithinBoundary(player)
  local character = player.Character
  return self.Region:CharacterIsInRegion(character)
end

return BaseModel
