local players = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")

local PlayerData = require(serverStorage.Data.PlayerData)

local function configurePlayer(player)
  -- Health does not play a part in the game and can be hidden from view.
  player.HealthDisplayDistance = 0

  -- Reduces the massive default zoom (400). Nobody needs to zoom out that far.
  player.CameraMaxZoomDistance = 100
end

players.PlayerAdded:connect(function(player)
  local data = PlayerData.new(player)
  data:AutoSave()

  players.PlayerRemoving:connect(function(leavingPlayer)
    if player == leavingPlayer then
      data:Save()
    end
  end)

  configurePlayer(player)
end)
