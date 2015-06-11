-- Name: Client.Main
-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local BindableAction = import("BindableAction")
local WaveRoad       = import("WaveRoad")
local WaveStation    = import("WaveStation")
local InteractionGui = import("InteractionGui")

-- A reference to the player's Character is not saved in a variable. This is
-- because Nevermore does not reset this script when the player dies.
--
-- Storing player.Character in a variable will point to an old character model
-- once the player dies.

local player = players.LocalPlayer
local playerGui = player.PlayerGui

local function isAlive(character)
  local humanoid = character:FindFirstChild("Humanoid")
  return humanoid.Health > 0
end


--------------------------------------------------------------------------------
-- Wave World Interaction
--------------------------------------------------------------------------------

local function handleWaveStation()
  local models = {
    SkyWave = replicatedStorage.SkyWave,
    WaveStation = workspace.SectionBottomLeft.WaveStation
  }

  local useWaveStation = BindableAction.FromData{
    ActionName = "UseWaveStation",
    CreateTouchButton = true,
    InputTypes = { Enum.KeyCode.E } }
  local useWaveStationMsg = "Press [E] to access the Wave World"
  local useWaveStationGui = InteractionGui.new(playerGui, useWaveStationMsg)

  local skyWave = WaveRoad.new(models.SkyWave)
  local waveStation = WaveStation.new(models.WaveStation, useWaveStation,
    useWaveStationGui)

  local function enterSkyWave()
    skyWave:Show()
    skyWave.Entered:FireServer()
  end

  -- This is triggered by the SkyWaveLeft event, and as such does not need to
  -- fire an event like enterSkyWave does.
  local function leaveSkyWave()
    skyWave:Hide()
  end

  local function runInteractionLoop()
    while true do
      local character = player.Character
      local rootPart = character:FindFirstChild("HumanoidRootPart")

      if isAlive(character) then
        waveStation:SetInteractionState(rootPart)
      end

      wait(.25) -- Abritrary delay. It feels good while playtesting.
    end
  end

  useWaveStation:BindFunction("Primary", enterSkyWave)
  skyWave.Left.OnClientEvent:connect(leaveSkyWave)
  coroutine.wrap(runInteractionLoop)()
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function initialize()
  nevermore.ClearSplash()
  handleWaveStation()
end

initialize()
