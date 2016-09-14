-- Name: Client.Main
-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local BindableAction = import("BindableAction")
local InteractableObject = import("InteractableObject")
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
  local action = BindableAction.FromData{
    ActionName = "UseWaveStation",
    CreateTouchButton = true,
    InputTypes = { Enum.KeyCode.E } }

  local model = workspace.SectionBottomLeft.WaveStation

  local msg = "Press [E] to access the Wave World"
  local gui = InteractionGui.new(playerGui, msg)

  local waveStationUsed = getRemoteEvent("WaveStationUsed")
  local waveStation = InteractableObject.new(model, action, gui)

  local function enterSkyWave(_, inputState)
    if inputState == Enum.UserInputState.End then return end
    waveStationUsed:FireServer()
  end
  action:BindFunction("Primary", enterSkyWave)

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
