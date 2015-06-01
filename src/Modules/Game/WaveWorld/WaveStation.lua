
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local BaseModel = import("BaseModel")

--------------------------------------------------------------------------------
-- Wave Station
--------------------------------------------------------------------------------

local WaveStation = {}
WaveStation.__index = WaveStation

function WaveStation.new(model, action, gui)
  local self = {}

  self.Model = BaseModel.new(model)
  self.Action = action
  self.PopupGui = gui

  return setmetatable(self, WaveStation)
end

function WaveStation:AllowInteraction()
  self.PopupGui:Show()
  self.Action:Bind()
end

function WaveStation:DenyInteraction()
  self.PopupGui:Hide()
  self.Action:Unbind()
end

function WaveStation:SetInteractionState(rootPart)
  local inRange = self.Model:PartInRange(rootPart, 10)
  local actionIsBound = self.Action:IsBound()

  -- If an action is bound or unbound twice, an error occurs. To compensate
  -- for this, we use a flip-flop style logic gate to toggle between bound and
  -- unbound.

  if inRange and not actionIsBound then
    self:AllowInteraction()
  elseif not inRange and actionIsBound then
    self:DenyInteraction()
  end
end

return WaveStation
