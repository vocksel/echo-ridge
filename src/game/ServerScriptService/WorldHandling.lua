local replicatedStorage = game:GetService("ReplicatedStorage")

local remotes = require(replicatedStorage.Events.Remotes)

local waveStationUsed = remotes.getEvent("WaveStationUsed")
local skyWave = workspace.SkyWave

-- Moves `model` on top of `part`.
--
-- This is used to move a Player's Character ontop of the teleport pad on the
-- Sky Wave.
local function teleportOnTop(model, part)
  local boundingBox = model:GetExtentsSize()
  local offset = CFrame.new(0, boundingBox.y, 0)
  model:SetPrimaryPartCFrame(part.CFrame * offset)
end

waveStationUsed.OnServerEvent:connect(function(player)
  teleportOnTop(player.Character, skyWave.TeleportPad)
end)
