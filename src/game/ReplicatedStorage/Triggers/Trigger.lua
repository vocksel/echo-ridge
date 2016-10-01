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

    This is used later so we can connect to its Touched event and monitor the
    area it emcompasses for objects.

  self.Touched
    A reference to triggerPart's Touched event.

    You should use this for all Touched-based interaction with the Trigger, as
    opposed to referencing triggerPart.Touched directly.

  Usage
  =====

    local triggerPart = workspace.TriggerPart
    local trigger = Trigger.new(triggerPart)

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

local Trigger = {}
Trigger.__index = Trigger

function Trigger.new(triggerPart)
  assert(expect.basePart(triggerPart), string.format("bad argument #1 to "..
    "'new' (Part expected, got %s)", expect.getType(triggerPart)))

  local self = {}
  setmetatable(self, Trigger)

  self.TriggerPart = triggerPart
  self.Touched = triggerPart.Touched

  return self
end

return Trigger
