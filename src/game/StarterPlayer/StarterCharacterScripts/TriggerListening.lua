-- ClassName: LocalScript

--[[
  Handles client-side trigger setup.

  This script instantiates all of the ClientTriggers and connects to their
  events to allow the user to "interact" with the game world by binding actions.

  Each CharacterTrigger has an associated RemoteEvent it can fire, and the
  server takes care of what happens next.

  For example, if you're in the trigger right outside the Wave Station,
  interacting will fire the "WaveStationUsed" RemoteEvent. The server then takes
  care of the rest by teleporting you onto the Sky Wave.
--]]

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local remotes = require(replicatedStorage.Events.Remotes)
local Interact = require(replicatedStorage.Interaction.Interact)
local CharacterTrigger = require(replicatedStorage.Triggers.CharacterTrigger)

local getTriggers = remotes.getFunction("GetTriggerParts")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()

local function setupTrigger(triggerPart)
  local trigger = CharacterTrigger.new(triggerPart, character)
  local interact = Interact.new()

  trigger:Connect()

  interact:SetBoundFunction(function(inputState)
    if inputState == Enum.UserInputState.End then return end
    trigger:FireEvent()
  end)

  trigger.CharacterEntered:connect(function()
    interact:Bind()
  end)

  trigger.CharacterLeft:connect(function()
    interact:Unbind()
  end)
end

local function setupExistingTriggers()
  local triggerParts = getTriggers:InvokeServer()
  for _, triggerPart in ipairs(triggerParts) do
    setupTrigger(triggerPart)
  end
end

setupExistingTriggers()
