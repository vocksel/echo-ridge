local replicatedStorage = game:GetService("ReplicatedStorage")

local BaseModel = require(replicatedStorage.Models.BaseModel)

local function teleportOnTop(model, part)
  local boundingBox = model:GetExtentsSize()
  local offset = CFrame.new(0, boundingBox.y, 0)
  model:SetPrimaryPartCFrame(part.CFrame * offset)
end


--------------------------------------------------------------------------------
-- Wave Road
--------------------------------------------------------------------------------

local WaveRoad = {}
WaveRoad.__index = WaveRoad
setmetatable(WaveRoad, BaseModel)

function WaveRoad.new(model)
  assert(model:FindFirstChild("TeleportPad"), tostring(model).." needs a Part named \"TeleportPad\".")

  local self = BaseModel.new(model)

  self.EntryPoint = model.TeleportPad

  return setmetatable(self, WaveRoad)
end

function WaveRoad:TransIn(player)
  -- Teleporting the player onto the Wave Road should only be done once you
  -- ensure that the model is in the Workspace.
  --
  -- If you teleport the player before the model is rendered, they will fall
  -- into the void.
  teleportOnTop(player.Character, self.EntryPoint)
end

return WaveRoad
