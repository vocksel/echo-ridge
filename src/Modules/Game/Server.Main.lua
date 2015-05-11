-- Name: Server.Main
-- ClassName: Script

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local data = import("Data")
local ServerWaveRoad = import("ServerWaveRoad")

--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------

--[[
  Internal: Configures properties of the game's Services.

  There is no publicly available file for this game, so it's best to configure
  properties progmatically so that the game is consistent between two place files.

  Setting properties this way also opens up the possibility to document why a
  property has been set to a certain value.
--]]
local function configureServices()
  -- When testing locally, scripts do not have a chance to connect to the
  -- PlayerAdded event before your player and character are loaded.
  --
  -- To combat this, a For loop is used to run onPlayerAdded on all existing
  -- players (just one, in this case).
  --
  -- But this does not account for the already existing character. Another loop
  -- could be used to run onCharacterAdded for the character, but loading the
  -- character manually ensures that CharacterAdded will fire.
  --
  -- I suspect the player and character loading before scripts is a side effect
  -- of how Nevermore moves everything around before enabling scripts. This used
  -- to be an issue with ROBLOX itself, but has since been fixed.
  --
  -- This is not an issue when running a test server or when online.
  players.CharacterAutoLoads = false
end

--[[
  Internal: Sets all the properties for the Player and their Character.

  playerEntity - An EntityPlayer to set ROBLOX properties for.
--]]
local function configurePlayer(player, character)
  local humanoid = character.Humanoid

  player.HealthDisplayDistance = 0
  player.CameraMaxZoomDistance = 100

  humanoid.NameOcclusion = "OccludeAll"
end


--------------------------------------------------------------------------------
-- Player Handling
--------------------------------------------------------------------------------

--[[
  Internal: Runs tasks on a newly joined Player

  An anonymous function can not be used in this case, because this function has
  to run both when PlayerAdded fires and when a Player is in solo mode.

  player - The Player that just joined the game.
--]]
local function onPlayerAdded(player)
  local joinTime = os.time()
  local saveData = data.getDataStore(tostring(player.userId), "PlayerData")
  local originalPlayTime = saveData:GetAsync("PlayTime") or 0

  local function updatePlayTime()
    -- Using PlayTime stored on the server is not recommended in this case.
    -- If you have a loop saving data every few seconds, then PlayTime would
    -- increase exponentially as sessionTime is added to it.
    --
    -- Getting PlayTime at the start ensures that the value won't get bloated,
    -- as originalPlayTime is not actually being incremented.
    local sessionTime = os.time() - joinTime
    return originalPlayTime + sessionTime
  end

  player.CharacterAdded:connect(function(character)
    configurePlayer(player, character)
  end)

  players.PlayerRemoving:connect(function(leavingPlayer)
    if player == leavingPlayer then
      saveData:UpdateAsync("PlayTime", updatePlayTime)
    end
  end)

  player:LoadCharacter()
end

--[[
  Internal: Properly loads a Player when testing in solo mode.

  When testing locally, scripts do not have a chance to connect to the
  PlayerAdded event before your player and character are loaded.

  I suspect the player and character loading before scripts is a side effect
  of how Nevermore moves everything around before enabling scripts. This used
  to be an issue with ROBLOX itself, but has since been fixed.

  This is not an issue when running a test server or when online.
--]]
local function handleExistingPlayers()
  local playerList = players:GetPlayers()
  for _,player in pairs(playerList) do
    coroutine.wrap(onPlayerAdded)(player)
  end
end


--------------------------------------------------------------------------------
-- Wave World
--------------------------------------------------------------------------------

local function handleWaveWorld()
  local skyWaveModel = replicatedStorage.SkyWave
  local skyWaveEntered = getRemoteEvent("SkyWaveEntered")
  local skyWave = ServerWaveRoad.new(skyWaveModel.TeleportPad)

  skyWaveEntered.OnServerEvent:connect(function(player)
    skyWave:TransIn(player)
  end)
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function initialize()
  nevermore.SetRespawnTime(3)
  configureServices()
  handleExistingPlayers()
  handleWaveWorld()
  players.PlayerAdded:connect(onPlayerAdded)
end

initialize()
