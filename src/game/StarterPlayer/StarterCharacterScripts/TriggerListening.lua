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
local InteractionPrompt = require(replicatedStorage.UI.InteractionPrompt)
local CharacterTrigger = require(replicatedStorage.Triggers.CharacterTrigger)

local getTriggers = remotes.getFunction("GetTriggerParts")

local client = players.LocalPlayer
local playerGui = client.PlayerGui
local character = client.Character or client.CharacterAdded:wait()

local function setupTrigger(triggerPart)
  local trigger = CharacterTrigger.new(triggerPart, character)
  local interact = Interact.new()

  -- This is a little messy but right now InteractionPrompt only works off of a
  -- keyboard key. Since Interact uses the keyboard as its first input type for
  -- ContextActionService, we index the list of inputs and get the name for the
  -- input.
  --
  -- Enums have a `Name` property which in this case is "E" for Enum.KeyCode.E,
  -- so we pass that in to the InteractionPrompt so it displays the correct key.
  local inputName = interact.Inputs[1].Name
  local prompt = InteractionPrompt.new(playerGui, inputName)

  trigger:Connect()

  interact:SetBoundFunction(function(inputState)
    if inputState == Enum.UserInputState.End then return end
    trigger:FireEvent()
  end)

  trigger.CharacterEntered:connect(function()
    prompt:Show()
    interact:Bind()
  end)

  trigger.CharacterLeft:connect(function()
    prompt:QuickHide()
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
