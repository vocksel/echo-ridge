local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local DataStore = import("DataStore")

--------------------------------------------------------------------------------
-- Player Data
--------------------------------------------------------------------------------

local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(player)
  local self = {}

  self.Data     = DataStore.new(tostring(player.userId), "PlayerData")
  self.JoinTime = os.time()
  self.PlayTime = self.Data:Get("PlayTime") or 0

  return setmetatable(self, PlayerData)
end

function PlayerData:UpdatePlayTime()
  local function updatePlayTime()
    -- We do not use the current value of PlayTime that's passed by
    -- UpdateAsync. PlayTime is stored in a variable so that it remains static.
    --
    -- This is in case PlayTime is updated more than once per session. Adding
    -- the current value of PlayTime with the session time will cause bloating.
    local sessionTime = os.time() - self.JoinTime
    return self.PlayTime + sessionTime
  end

  self.Data:Update("PlayTime", updatePlayTime)
end

function PlayerData:Save()
  self:UpdatePlayTime()
end

function PlayerData:AutoSave(time)
  time = time or 30

  local function saveLoop()
    while wait(time) do
      self:Save()
    end
  end

  coroutine.wrap(saveLoop)()
end

return PlayerData
