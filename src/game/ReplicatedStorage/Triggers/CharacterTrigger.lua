--[[
  CharacterTrigger
  ================

  Trigger for Character detection.

  This is typically used by the client so that they can detect when their
  Character is inside one of the Trigger Parts. They then bind actions while
  they're inside the trigger so they can interact with the world.

  Each Trigger Part used with this class needs a `TriggerData` module with a
  `FiredEvent` property, which is the name of the RemoteEvent to fire when the
  user interacts while inside of the Trigger Part.

  Connstructors
  =============

  CharacterTrigger.new(Part triggerPart, Model character)
    Returns a new CharacterTrigger with `triggerPart` as the Part it uses to
    determine the area of the trigger, and `character` as what it monitors for.

  Properties
  ==========

  self.Region
    A Region3 created from triggerPart. This is used to detect when an object
    leaves triggerPart.

  Methods
  =======

  DetectCharacterInTrigger()
    Runs a loop to make sure `character` is still inside the region. If not,
    fires ClientLeft.

  TouchListner(Part otherPart)
    Listens for `character` coming in contact with the Trigger. Fires
    ClientEntered.

  FireEvent()
    Fires the event the Trigger manages to the server.

  Events
  ======

  CharacterEntered
    Fired when `character` first comes in contact with the Trigger Part.

  CharacterLeft
    Fire when `character` leaves the Trigger's region.

    The detection for this starts right away, so the character can't touch and
    then walk away from the Trigger without this firing.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")

local remotes = require(replicatedStorage.Events.Remotes)
local Signal = require(replicatedStorage.Events.Signal)
local BaseTrigger = require(script.Parent.BaseTrigger)
local Region = require(replicatedStorage.Region)

-- Gets the Characters's HumanoidRootPart.
--
-- This is used so we can check if the Character the Trigger manages is the same
-- one that just came in contact with the Trigger Part.
local function getRootPart(character)
  return character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------------------------------------

local CharacterTrigger = {}
CharacterTrigger.__index = CharacterTrigger
setmetatable(CharacterTrigger, BaseTrigger)

function CharacterTrigger.new(triggerPart, character)
  local triggerData = triggerPart:FindFirstChild("TriggerData")
  assert(triggerData, "argument #1 must have a ModuleScript named "..
    "\"TriggerData\" as a child.")

  local self = BaseTrigger.new(triggerPart)

  self.TriggerData = require(triggerData)
  self.FiredEvent = remotes.getEvent(self.TriggerData.FiredEvent)
  self.WatchedCharacter = character
  self.Region = Region.fromPart(triggerPart)

  self.CharacterEntered = Signal.new()
  self.CharacterLeft = Signal.new()

  return setmetatable(self, CharacterTrigger)
end

function CharacterTrigger:DetectCharacterInTrigger()
  local conn
  conn = run.Heartbeat:connect(function()
    if not self.Region:CharacterIsInRegion(self.WatchedCharacter) then
      self.CharacterLeft:fire()
      conn:disconnect()
    end
  end)
end

function CharacterTrigger:TouchListener(otherPart)
  self.Touched:connect(function(otherPart)
    local rootPart = getRootPart(self.WatchedCharacter)
    if otherPart == rootPart then
      self.CharacterEntered:fire()
      self:DetectCharacterInTrigger()
    end
  end)
end

function CharacterTrigger:FireEvent()
  self.FiredEvent:FireServer()
end

return CharacterTrigger
