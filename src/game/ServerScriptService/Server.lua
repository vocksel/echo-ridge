local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScripts = game:GetService("ServerScriptService")

local remotes = require(replicatedStorage.Events.Remotes)
local WaveRoad = require(serverScripts.WaveWorld.WaveRoad)
local PlayerData = require(serverScripts.Data.PlayerData)
local World = require(serverScripts.Environment.World)
local Cell = require(serverScripts.Environment.Cell)

local cells = {
  EchoRidge = Cell.new("EchoRidge"),
  SkyWave = Cell.new("SkyWave")
}

local world = World.new(cells)


--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------

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

  configurePlayer(player)

  -- Start the player off in Echo Ridge
  world:EnterCell(cells.EchoRidge, player)
end


--------------------------------------------------------------------------------
-- Wave World
--------------------------------------------------------------------------------

local function handleWaveWorld()
  local skyWaveModel = replicatedStorage.SkyWave
  local skyWave = WaveRoad.new(skyWaveModel)
  local waveStationUsed = remotes.getEvent("WaveStationUsed")

  -- Always move players between cells *before* calling this function. The Sky
  -- Wave's player list needs to be up-to-date before checking if it should be
  -- shown or hidden.
  local function setSkyWaveVisibility()
    local skyWavePlayers = cells.SkyWave:GetPlayers()

    if #skyWavePlayers == 1 then
      skyWave:Show()
    elseif #skyWavePlayers == 0 then
      skyWave:Hide()
    end
  end

  local function enterSkyWave(player)
    world:EnterCell(cells.SkyWave, player)
    setSkyWaveVisibility()
    skyWave:TransIn(player)
  end

  local function leaveSkyWave(player)
    world:EnterCell(cells.EchoRidge, player)
    setSkyWaveVisibility()
  end

  local function detectOutOfBounds(player)
    while true do
      if not skyWave:PlayerWithinBoundary(player) then
        leaveSkyWave(player)
        break
      end
      wait(.25)
    end
  end

  local function onWaveStationUsed(player)
    enterSkyWave(player)
    coroutine.wrap(detectOutOfBounds)(player)
  end

  waveStationUsed.OnServerEvent:connect(onWaveStationUsed)
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function initialize()
  handleWaveWorld()
  players.PlayerAdded:connect(onPlayerAdded)
end

initialize()
