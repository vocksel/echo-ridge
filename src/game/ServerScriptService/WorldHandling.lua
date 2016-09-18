local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScripts = game:GetService("ServerScriptService")

local remotes = require(replicatedStorage.Events.Remotes)
local WaveRoad = require(serverScripts.WaveWorld.WaveRoad)
local World = require(serverScripts.Environment.World)
local Cell = require(serverScripts.Environment.Cell)

local cells = {
  EchoRidge = Cell.new("EchoRidge"),
  SkyWave = Cell.new("SkyWave")
}

local world = World.new(cells)

players.PlayerAdded:connect(function(player)
  players.PlayerRemoving:connect(function(leavingPlayer)
    if player == leavingPlayer then
      world:LeaveCurrentCell(player)
    end
  end)
  -- Start the player off in Echo Ridge
  world:EnterCell(cells.EchoRidge, player)
end)

local function handleWaveWorld()
  local skyWaveModel = workspace.SkyWave
  local skyWave = WaveRoad.new(skyWaveModel)
  local waveStationUsed = remotes.getEvent("WaveStationUsed")

  local function enterSkyWave(player)
    world:EnterCell(cells.SkyWave, player)
    skyWave:TransIn(player)
  end

  local function leaveSkyWave(player)
    world:EnterCell(cells.EchoRidge, player)
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

handleWaveWorld()
