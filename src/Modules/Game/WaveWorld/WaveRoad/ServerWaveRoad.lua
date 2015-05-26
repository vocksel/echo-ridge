
local ServerWaveRoad = {}
ServerWaveRoad.__index = ServerWaveRoad

local function teleportOnTop(model, part)
  local boundingBox = model:GetExtentsSize()
  local offset = CFrame.new(0, boundingBox.y, 0)
  model:SetPrimaryPartCFrame(part.CFrame * offset)
end

function ServerWaveRoad.new(entrance)
  local self = {}

  self.EntryPoint = entrance

  return setmetatable(self, ServerWaveRoad)
end

-- Teleporting the player onto their Wave Road should only be done once you
-- ensure that it is being rendered locally. Otherwise the player will fall
-- into the void.

function ServerWaveRoad:TransIn(player)
  teleportOnTop(player.Character, self.EntryPoint)
end

return ServerWaveRoad
