-- Name: Client.Main
-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local BindableAction = import("BindableAction")
local WaveRoad       = import("WaveRoad")
local WaveStation    = import("WaveStation")
local InteractionGui = import("InteractionGui")

-- A reference to the player's Character is not saved in a variable. This is
-- because Nevermore does not reset this script when the player dies.
--
-- Storing player.Character in a variable will eventually point to an old
-- character model once the player dies.

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
  local skyWaveModel = replicatedStorage.SkyWave
  local skyWave = WaveRoad.new(skyWaveModel)

  local skyWaveEntered = getRemoteEvent("SkyWaveEntered")
  local skyWaveLeft = getRemoteEvent("SkyWaveLeft")

  local function onSkyWaveLeft()
    skyWave:Hide()
  end
  skyWaveLeft.OnClientEvent:connect(onSkyWaveLeft)

  local function getWaveStationComponents()
    local model = workspace.SectionBottomLeft.WaveStation

    local function interact(_, inputState)
      if inputState == Enum.UserInputState.End then return end
      skyWave:Show()
      skyWaveEntered:FireServer()
    end

    local action = BindableAction.FromData{
      ActionName = "UseWaveStation",
      FunctionToBind = interact,
      CreateTouchButton = true,
      InputTypes = { Enum.KeyCode.E }
    }

    local msg = "Press [E] to access the Wave World"
    local gui = InteractionGui.new(playerGui, msg)

    return model, action, gui
  end

  local model, action, gui = getWaveStationComponents()
  local waveStation = WaveStation.new(model, action, gui)

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
