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
local contextAction = game:GetService("ContextActionService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local ACTION_NAME = "Interact"
local ACTION_KEY = Enum.KeyCode.E

local remotes = require(replicatedStorage.Events.Remotes)
local CharacterTrigger = require(replicatedStorage.Triggers.CharacterTrigger)

local getTriggers = remotes.getFunction("GetTriggerParts")
local triggerAdded = remotes.getEvent("TriggerPartAdded")
local triggerRemoved = remotes.getEvent("TriggerRemoved")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()

local function setupTrigger(triggerPart)
  local trigger = CharacterTrigger.new(triggerPart, character)
  trigger:Connect()

  local function action(_, inputState)
    if inputState == Enum.UserInputState.End then return end
    trigger:FireEvent()
  end

  trigger.CharacterEntered:connect(function()
    contextAction:BindAction(ACTION_NAME, action, true, ACTION_KEY)
  end)

  trigger.CharacterLeft:connect(function()
    contextAction:UnbindAction(ACTION_NAME)
  end)
end

local function setupExistingTriggers()
  local triggerParts = getTriggers:InvokeServer()
  for _, triggerPart in ipairs(triggerParts) do
    setupTrigger(triggerPart)
  end
end

setupExistingTriggers()
triggerAdded.OnClientEvent:connect(setupTrigger)
