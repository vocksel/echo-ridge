-- ClassName: LocalScript

--[[
  Handles user interaction with triggers.

  The server code explains what a trigger is, you can find it in:
  game.ServerScriptService.TriggerHandling

  This script connects all of the triggers to events that then allow the player
  to "interact" with the game world by the user of ContextActionService.

  Each trigger has a "TriggerData" module inside of it, which currently is only
  used to define a `firedEvent` property. This is the name of a RemoteEvent that
  gets fired when the user interacts.

  From there the server takes care of what happens next. For example, if you're
  in the trigger right outside the Wave Station, the server will teleport you to
  the Sky Wave.
--]]

local players = game:GetService("Players")
local contextAction = game:GetService("ContextActionService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local ACTION_NAME = "Interact"
local ACTION_KEY = Enum.KeyCode.E

local remotes = require(replicatedStorage.Events.Remotes)

local getTriggers = remotes.getFunction("GetInteractionTriggers")
local triggerAdded = remotes.getEvent("TriggerAdded")
local triggerRemoved = remotes.getEvent("TriggerRemoved")

local player = players.LocalPlayer

-- Checks if `part` is the clients HumanoidRootPart.
--
-- This is used when checking what touched the trigger so that we only have to
-- worry about a single part and none of the other limbs/hats.
local function isClientsRootPart(part)
  return part == player.Character.HumanoidRootPart
end

-- Fires the event that was set for `trigger`.
local function runTriggerEvent(trigger)
  local triggerData = require(trigger.TriggerData)
  local event = remotes.getEvent(triggerData.firedEvent)

  event:FireServer()
end

-- Fired when the trigger is touched.
--
-- This is what sets up the interaction code so the player can actually interact
-- with the triggers.
local function onTriggerTouched(trigger, otherPart)
  if isClientsRootPart(otherPart) then
    local function action(_, inputState)
      if inputState == Enum.UserInputState.End then return end
      runTriggerEvent(trigger)
    end

    contextAction:BindAction(ACTION_NAME, action, true, ACTION_KEY)
  end
end

-- Fired when the player leaves the trigger.
--
-- Simply unbinds the event so the player can't interact anymore.
--
-- BUG: If the player is teleported out of the trigger, this will not fire. So
-- currently we have a pretty big problem of the player being able to
-- continuously interact even when they're on the Sky Wave, thus teleporting
-- them back to the teleport pad.
--
-- This will be removed or reworked to function properly in the future. Right
-- now its being kept because it /kinda/ works, and we just need to get all
-- these interaction changes commited.
local function onTriggerTouchEnded(_, otherPart)
  if isClientsRootPart(otherPart) then
    contextAction:UnbindAction(ACTION_NAME)
  end
end

-- Connection functions for Touched and TouchEnded.
--
-- We have to pass in an anonymous function because we need the trigger later
-- on down the line when we get to user itneraction.
local function connectTriggerTouched(trigger)
  return trigger.Touched:connect(function(...)
    onTriggerTouched(trigger, ...)
  end)
end

local function connectTriggerTouchEnded(trigger)
  return trigger.TouchEnded:connect(function(...)
    onTriggerTouchEnded(trigger, ...)
  end)
end

-- Hooks up all the events for the trigger and makes sure everything is cleaned
-- up properly when it's removed.
local function connectTriggerEvents(trigger)
  local touchedConn = connectTriggerTouched(trigger)
  local touchEndedConn = connectTriggerTouchEnded(trigger)

  triggerRemoved.OnClientEvent:connect(function(removedTrigger)
    if removedTrigger == trigger then
      touchedConn:disconnect()
      touchEndedConn:disconnect()
    end
  end)
end

-- Simple loop to connect all of the existing triggers.
local function connectExistingTriggers()
  local triggers = getTriggers:InvokeServer()
  for _, trigger in ipairs(triggers) do
    connectTriggerEvents(trigger)
  end
end

-- Connects any new triggers that get added.
local function connectNewTriggers()
  triggerAdded.OnClientEvent:connect(function(addedTrigger)
    connectTriggerEvents(addedTrigger)
  end)
end

connectExistingTriggers()
connectNewTriggers()
