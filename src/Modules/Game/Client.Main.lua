-- Name: Client.Main
-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local actionBinding     = import("ActionBinding")
local bindAction        = actionBinding.bindAction
local unbindAction      = actionBinding.unbindAction
local ClientWaveRoad    = import("ClientWaveRoad")
local ClientWaveStation = import("ClientWaveStation")

local player = players.LocalPlayer
local playerGui = player.PlayerGui


--------------------------------------------------------------------------------
-- Wave World Interaction
--------------------------------------------------------------------------------

local function handleWaveStation()
  local skyWaveModel     = replicatedStorage.SkyWave
  local waveStationModel = workspace.SectionBottomLeft.WaveStation
  local skyWave          = ClientWaveRoad.new(skyWaveModel)
  local waveStation      = ClientWaveStation.new(waveStationModel)
  local skyWaveEntered   = getRemoteEvent("SkyWaveEntered")

  local gui = playerGui.PressKeyToInteract.Frame
  local offScreenPos = gui.Position
  local onScreenPos  = offScreenPos - UDim2.new(0, 0, .25, 0)

  local function showInteractionGui()
    if gui.Position == offScreenPos then
      gui:TweenPosition(onScreenPos, "Out", "Quart", .5, true)
    end
  end

  local function hideInteractionGui()
    gui.Position = offScreenPos
  end

  local function interact(_, inputState)
    if inputState == Enum.UserInputState.End then return end
    skyWave:Show()
    skyWaveEntered:FireServer(skyWaveModel)
  end

  local function setBindingState()
    if waveStation:InRange(player, 10) then
      showInteractionGui()
      bindAction("UseWaveStation", interact, true, Enum.KeyCode.E)
    else
      hideInteractionGui()
      unbindAction("UseWaveStation")
    end
  end

  local function runInteractionLoop()
    while true do
      setBindingState()
      wait(.25) -- Abritrary delay. It feels good while playtesting.
    end
  end

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
