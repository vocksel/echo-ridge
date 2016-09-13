
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local BaseModel = import("BaseModel")

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

  -- Keep the original parent in memory so that the Wave Road can be moved back
  -- later (Thus hiding it from view).
  self.OrigParent = model.Parent

  -- This condition will automatically determine if the model is visible or not.
  --
  -- The Workspace is the only container that renders objects, so if the model
  -- is parented to it we know it can be seen, and vice versa.
  self.Visible = model.Parent == workspace

  self.EntryPoint = model.TeleportPad

  return setmetatable(self, WaveRoad)
end

function WaveRoad:Show()
  self.Model.Parent = workspace
  self.Visible = true
end

function WaveRoad:Hide()
  self.Model.Parent = self.OrigParent
  self.Visible = false
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
