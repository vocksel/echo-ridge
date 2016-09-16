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
local run = game:GetService("RunService")

local ACTION_NAME = "Interact"
local ACTION_KEY = Enum.KeyCode.E

local remotes = require(replicatedStorage.Events.Remotes)
local Region = require(replicatedStorage.Regions.Region)

local getTriggers = remotes.getFunction("GetInteractionTriggers")
local triggerAdded = remotes.getEvent("TriggerAdded")
local triggerRemoved = remotes.getEvent("TriggerRemoved")

local player = players.LocalPlayer
local character = player.Character
local rootPart = character:FindFirstChild("HumanoidRootPart")

-- Checks if `part` is the clients HumanoidRootPart.
--
-- This is used when checking what touched the trigger so that we only have to
-- worry about a single part and none of the other limbs/hats.
local function isClientsRootPart(part)
  return part == rootPart
end

-- Checks if the player is within the given region.
local function playerIsInRegion(region)
  return region:CastPart(rootPart)
end

-- Fires the event that was set for `trigger`.
local function runTriggerEvent(trigger)
  local triggerData = require(trigger.TriggerData)
  local event = remotes.getEvent(triggerData.firedEvent)

  event:FireServer()
end

-- Unbinds the interaction action if the player is outside of `region`.
--
-- This is used to make sure the player is still inside of the trigger. Once
-- they're not we need to unbind the action so they can't interact from across
-- the map.
--
-- Previously we were using the TouchEnded event instead of a region loop. This
-- almost satisfied our needs, but it had a very big problem where if you
-- teleport the user outside of the trigger, TouchEnded wouldn't fire.
--
-- This left the interact action still bound, so the client could teleport to
-- the Wave Road from any location. We're now using a region check to be
-- absolutely sure if the player is still inside the trigger or not.
local function unbindIfOutOfRegion(region)
  local conn
  conn = run.Heartbeat:connect(function()
    if not playerIsInRegion(region) then
      contextAction:UnbindAction(ACTION_NAME)
      conn:disconnect()
    end
  end)
end

-- Hooks up all the events for a trigger.
--
-- We have to pass in an anonymous function because we need the trigger later
-- on down the line when we get to user itneraction.
local function connectTriggerEvents(trigger)
  local region = Region.FromPart(trigger)

  local function action(_, inputState)
    if inputState == Enum.UserInputState.End then return end
    runTriggerEvent(trigger)
  end

  trigger.Touched:connect(function(otherPart)
    if isClientsRootPart(otherPart) then
      contextAction:BindAction(ACTION_NAME, action, true, ACTION_KEY)
      unbindIfOutOfRegion(region)
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

connectExistingTriggers()

triggerAdded.OnClientEvent:connect(function(addedTrigger)
  connectTriggerEvents(addedTrigger)
end)
