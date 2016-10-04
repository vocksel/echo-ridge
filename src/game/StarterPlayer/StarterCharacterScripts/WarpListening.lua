-- ClassName: LocalScript

--[[
  WarpListening
  =============

  Hooks up the Warps in the game to allow the player to travel between areas in
  the overworld and interiors.
--]]

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local remotes = require(replicatedStorage.Events.Remotes)
local Warp = require(replicatedStorage.Warping.Warp)
local Trigger = require(replicatedStorage.Triggers.Trigger)

local client = players.LocalPlayer
local playerGui = client.PlayerGui
local character = client.Character
local rootPart = character:FindFirstChild("HumanoidRootPart")

local getComponents = remotes.getFunction("GetComponents")

local function setupTriggerWarps()
  local function setupTrigger(warp, triggerPart)
    local trigger = Trigger.new(triggerPart)

    trigger.Touched:connect(function(otherPart)
      if otherPart == rootPart then
        warp:TeleportToPad(character)
      end
    end)
  end

  local function setupWarp(warpModel)
    local linkedWarp = warpModel.LinkedWarp.Value
    local triggerPart = warpModel.Trigger
    local warp = Warp.new(linkedWarp.Pad)

    setupTrigger(warp, triggerPart)
  end

  local triggerWarps = getComponents:InvokeServer("TriggerWarp")

  for _, warpModel in ipairs(triggerWarps) do
    setupWarp(warpModel)
  end
end

local function setupActionWarps()
  local Interact = require(replicatedStorage.Interaction.Interact)
  local InteractionPrompt = require(replicatedStorage.UI.InteractionPrompt)
  local CharacterTrigger = require(replicatedStorage.Triggers.CharacterTrigger)

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

  local function setupTrigger(warp, triggerPart)
    local trigger = CharacterTrigger.new(triggerPart, character)
    trigger:TouchListener()

    local function action(inputState)
      if inputState == Enum.UserInputState.End then return end
      warp:TeleportToPad(character)
    end

    trigger.CharacterEntered:connect(function()
      prompt:Show()
      interact:SetBoundFunction(action)
      interact:Bind()
    end)

    trigger.CharacterLeft:connect(function()
      prompt:QuickHide()
      interact:Unbind()
    end)
  end

  local function setupWarp(warpModel)
    local linkedWarp = warpModel.LinkedWarp.Value
    local triggerPart = warpModel.Trigger
    local warp = Warp.new(linkedWarp.Pad)

    setupTrigger(warp, triggerPart)
  end

  local actionWarps = getComponents:InvokeServer("ActionWarp")

  for _, warpModel in ipairs(actionWarps) do
    setupWarp(warpModel)
  end
end

setupTriggerWarps()
setupActionWarps()
