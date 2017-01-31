--[[
  WarpListening
  =============

  Hooks up the Warps in the game to allow the player to travel between areas in
  the overworld and interiors.
--]]

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local components = require(replicatedStorage.Services.ComponentService)
local transmit = require(replicatedStorage.Events.Transmit)
local Warp = require(replicatedStorage.Warping.Warp)
local CharacterTrigger = require(replicatedStorage.Triggers.CharacterTrigger)
local Interact = require(replicatedStorage.Interaction.Interact)
local InteractionPrompt = require(replicatedStorage.UI.InteractionPrompt)

local client = players.LocalPlayer
local playerGui = client.PlayerGui
local character = client.Character

-- We fire this once the client has been warped. This then passes off the
-- changing of Cells to StarterPlayerScripts.CellHandler.
local warpedToCell = transmit.getLocalEvent("WarpedToCell")

local interact = Interact.new()
local prompt do
  -- This is a little messy but right now InteractionPrompt only works off of a
  -- keyboard key. Since Interact uses the keyboard as its first input type for
  -- ContextActionService, we index the list of inputs and get the name for the
  -- input.
  --
  -- Enums have a `Name` property which in this case is "E" for Enum.KeyCode.E,
  -- so we pass that in to the InteractionPrompt so it displays the correct key.
  local inputName = interact.Inputs[1].Name
  prompt = InteractionPrompt.new(playerGui, inputName)
end

-- Allows you to check if an Instance is a child of one of the Cell Components.
--
-- This is used to check if the Warp's Pad the client has just been teleported
-- to is inside a Cell.
local function getParentCell(object)
  local cellModels = components:GetByType("Cell")

  for _, cellModel in ipairs(cellModels) do
    if object:IsDescendantOf(cellModel) then
      return cellModel
    end
  end
end

--------------------------------------------------------------------------------
-- Warp Setup
--------------------------------------------------------------------------------

local function getWarpComponents(warpModel)
  local linkedWarp = warpModel.LinkedWarp.Value
  local warp = Warp.new(linkedWarp.Pad)

  local triggerPart = warpModel.Trigger
  local trigger = CharacterTrigger.new(triggerPart, character)

  trigger:TouchListener()

  return warp, trigger
end

local function setupTriggerWarp(warp, trigger)
  trigger.Touched:connect(function()
    warp:TeleportToPad(character)
  end)
end

local function setupActionWarp(warp, trigger)
  local function action(inputState)
    if inputState == Enum.UserInputState.End then return end
    warp:TeleportToPad(character)
  end

  trigger.Touched:connect(function()
    prompt:Show()
    interact:SetBoundFunction(action)
    interact:Bind()
  end)

  trigger.TouchEnded:connect(function()
    prompt:QuickHide()
    interact:Unbind()
  end)
end

-- Based on the type of Warp we're dealing with, we need to route it to a
-- specific setup functions.
local function setupWarp(warpType, warpModel)
  local warp, trigger = getWarpComponents(warpModel)
  local parentCell = getParentCell(warp.Pad)

  if parentCell then
    warp.Warped:connect(function()
      warpedToCell:Fire(parentCell)
    end)
  end

  if warpType == "Trigger" then
    setupTriggerWarp(warp, trigger)
  elseif warpType == "Action" then
    setupActionWarp(warp, trigger)
  end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function init()
  local warpModels = components:GetByType("Warp")

  for _, warpModel in ipairs(warpModels) do
    local warpType = warpModel:FindFirstChild("WarpType")
    setupWarp(warpType.Value, warpModel)
  end
end

init()
