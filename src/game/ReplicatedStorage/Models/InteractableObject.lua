local replicatedStorage = game:GetService("ReplicatedStorage")

local BaseModel = require(script.Parent.BaseModel)

--------------------------------------------------------------------------------
-- InteractableObject
--------------------------------------------------------------------------------

local InteractableObject = {}
InteractableObject.__index = InteractableObject

function InteractableObject.new(model, action, gui)
  local self = {}

  self.Model = BaseModel.new(model)
  self.Action = action
  self.PopupGui = gui

  return setmetatable(self, InteractableObject)
end

function InteractableObject:AllowInteraction()
  self.PopupGui:Show()
  self.Action:Bind()
end

function InteractableObject:DenyInteraction()
  self.PopupGui:Hide()
  self.Action:Unbind()
end

function InteractableObject:SetInteractionState(rootPart)
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

return InteractableObject
