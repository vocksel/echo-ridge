-- Name: Server.Main
-- ClassName: Script

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local WaveRoad = import("WaveRoad")
local PlayerData = import("PlayerData")
local World = import("World")
local Cell = import("Cell")

local cells = {
  EchoRidge = Cell.new("EchoRidge"),
  SkyWave = Cell.new("SkyWave")
}

local world = World.new(cells)


--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------

--[[
  Internal: Configures properties of the game's Services.

  There is no publicly available rbxl file for the game, so it's best to
  configure properties progmatically. That way the game is consistent between
  two developer's level files.

  This way also opens up the possibility to document why a property has been set
  to a certain value.
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

local function configurePlayer(player)
  -- Health does not play a part in the game and can be hidden from view.
  player.HealthDisplayDistance = 0

  -- Reduces the massive default zoom (400). Nobody needs to zoom out that far.
  player.CameraMaxZoomDistance = 100
end

local function configureCharacter(character)
  local humanoid = character.Humanoid
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
  local data = PlayerData.new(player)
  data:AutoSave()

  local function onChaarcterAdded(character)
    configureCharacter(character)
  end

  local function onPlayerRemoving(leavingPlayer)
    if player == leavingPlayer then
      data:Save()
      world:LeaveCurrentCell(player)
    end
  end

  player.CharacterAdded:connect(onChaarcterAdded)
  players.PlayerRemoving:connect(onPlayerRemoving)

  player:LoadCharacter()
  configurePlayer(player)

  -- Start the player off in Echo Ridge
  world:EnterCell(cells.EchoRidge, player)
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
  local skyWave = WaveRoad.new(skyWaveModel)
  local skyWaveEntered = getRemoteEvent("SkyWaveEntered")
  local skyWaveLeft = getRemoteEvent("SkyWaveLeft")

  local function detectOutOfBounds(player)
    while true do
      if not skyWave:PlayerWithinBoundary(player) then
        skyWaveLeft:FireClient(player)
        break
      end
      wait(.25)
    end
  end

  local function onSkyWaveEntered(player)
    skyWave:TransIn(player)
    world:EnterCell(cells.SkyWave, player)
    coroutine.wrap(detectOutOfBounds)(player)
  end

  local function onSkyWaveLeft(player)
    world:EnterCell(cells.EchoRidge, player)
  end

  skyWaveEntered.OnServerEvent:connect(onSkyWaveEntered)
  skyWaveLeft.OnServerEvent:connect(onSkyWaveLeft)
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
