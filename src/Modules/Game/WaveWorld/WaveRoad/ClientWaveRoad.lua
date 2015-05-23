
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local BaseModel = import("BaseModel")


--------------------------------------------------------------------------------
-- Client Wave Road
--------------------------------------------------------------------------------

local ClientWaveRoad = {}
ClientWaveRoad.__index = ClientWaveRoad
setmetatable(ClientWaveRoad, BaseModel)

function ClientWaveRoad.new(model)
  local self = BaseModel.new(model)

  -- Keep the original parent in memory so that the Wave Road can be moved back
  -- later (Thus hiding it from view).
  self.OrigParent = model.Parent

  return setmetatable(self, ClientWaveRoad)
end

function ClientWaveRoad:Show()
  self.Model.Parent = workspace
end

function ClientWaveRoad:Hide()
  self.Model.Parent = self.OrigParent
end

return ClientWaveRoad
