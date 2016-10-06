--[[
  Trigger
  =======

  This is the base Trigger class. It doesn't do much on it's own, but it acts
  primarily as a foundation for other classes to extend off of.

  A "trigger" conceptually (not a Trigger class) is an area in the game world
  that we monitor for events. For example, games in The Legend of Zelda series
  use triggers to know when the player has reached a certain point in the game,
  and can then play a cutscene, close a door, or perform a similar event.

  A Trigger *class* takes a Part and applies this concept to it, turning the
  Part into an area we can monitor.

  This class simply makes use of the Part's Touched event, but sub-classes
  extend this functionality to make highly specialized cases for when something
  has been triggered.

  Constructors
  ============

  Trigger.new(Part triggerPart)
    Constructs a new Trigger using triggerPart as the area it manages.

  Properties
  ==========

  self.TriggerPart
    A reference to triggerPart.

    This is used internally so we can connect to its Touched event and monitor
    the area it emcompasses for objects.

  self.Whitelist
    This is a Array instance which contains all of the Parts that are allowed to
    interact with the Trigger.

    When empty, this is ignored and all Parts are detected.

  Methods
  =======

  HandleTouch(Part otherPart)
    Called by TouchListener() when a Part makes it through validation.

  TouchListener()
    Starts up all the touch listening.

    You have to call this right after creating the Trigger, otherwise there will
    be no touch detection.

    This method acts as a sort of gatekeeper, only Parts in the whitelist (or if
    there's no whitelist, any Part) are allowed through to HandleTouch().

  Events
  ======

  Touched
    Fired when a whitelisted Part touches the Trigger.

    If the whitelist is empty, any Part will fire this event.

  Usage
  =====

    local triggerPart = workspace.TriggerPart
    local trigger = Trigger.new(triggerPart)

    trigger:TouchListener()

    trigger.Touched:connect(function()
      print("Touched")
    end)

  More Info
  =========

  A Part was decided on as the representation for Triggers mainly because of its
  Touched event, but also because it makes it very simple to define the area a
  Trigger manages by moving and resizing the Part.

  In development, you can unhide all of the Trigger Parts and know exactly where
  each Trigger is and the space it takes up, and when prepraring for production
  you can hide them again.

  History
  =======

  In earlier versions, we used the TouchEnded event to check when an object left
  the Trigger Part, but this didn't satisfy our needs in the end. When an object
  is teleported outside of a Part, the TouchEnded event will not fire.

  Subclasses are used to teleport the Player to different locations in the game,
  because TouchEnded never fired, this left client-side actions bound even while
  outside of the trigger, allowing the player to (for instance) teleport onto
  the Sky Wave from anywhere in the game.

  Because of this, we had to scrap the TouchEnded functionality in favor of
  Region3s. This means we can't rotate the Triggers, but it's a small price to
  pay for guaranteed detection.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local expect = require(replicatedStorage.Util.Expect)
local Array = require(replicatedStorage.Util.Array)
local Signal = require(replicatedStorage.Events.Signal)

local Trigger = {}
Trigger.__index = Trigger

function Trigger.new(triggerPart)
  assert(expect.basePart(triggerPart), string.format("bad argument #1 to "..
    "'new' (Part expected, got %s)", expect.getType(triggerPart)))

  local self = {}
  setmetatable(self, Trigger)

  self.TriggerPart = triggerPart
  self.Whitelist = Array.new()

  self.Touched = Signal.new()

  return self
end

function Trigger:HandleTouch(otherPart)
  self.Touched:fire(otherPart)
end

function Trigger:TouchListener()
  self.TriggerPart.Touched:connect(function(otherPart)
    if self.Whitelist:IsEmpty() or self.Whitelist:Has(otherPart) then
      self:HandleTouch(otherPart)
    end
  end)
end

return Trigger
