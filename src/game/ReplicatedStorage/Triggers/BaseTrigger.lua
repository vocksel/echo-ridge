--[[
  BaseTrigger
  ===========

  Abstract base class for Triggers.

  As this is an abstract class, it should only be used for extending. This class
  is not intended to be instantiated on its own

  A "trigger" conceptually (not a Trigger class) is an area in the game world
  that we monitor for events. For example, games like The Legend of Zelda use
  triggers to know when the player has reached a certain point, then running a
  cutscene or similar event.

  A trigger is almost exactly like a Region3, only its based off of a Part so we
  can detect when its touched. In fact, we even implement Region3s to check when
  objects leave the trigger. This comes with the downside of not being able to
  rotate the Trigger's Part, as Region3s don't support it currently, but it's a
  small price to pay for built-in area detection.

  Using Parts and Region3s in this way makes for very efficient event-based
  area detection, as loops will only run once something comes in contact with
  the Trigger's Part.

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

  Constructors
  ============

  BaseTrigger.new(Part triggerPart)
    Constructs a new BaseTrigger using triggerPart as the area it manages.

    You typically won't use this function except for inheritence in subclasses.
    BaseTrigger has very minimal functionality, it's not intended to be used by
    itself.

  Properties
  ==========

  self.TriggerPart
    A reference to triggerPart that you pass in when instantiating.

    This is used later so we can connect to its Touched event and monitor the
    area it emcompasses for objects.

  self.Region
    A Region3 created from triggerPart. This is used to detect when an object
    leaves triggerPart.

  Methods
  =======

  self:TouchListner(Part otherPart)
    This is automatically called whenever triggerPart is touched.

    By default, this will throw an error. You are expected to extend this class
    and override this method to define what should happen when triggerPart is
    touched.

  Connect()
    After instatiating you should call this immediately.

    This kicks everything off by listening for when triggerPart is touched.

    It connect's triggerPart's Touched event to TouchListner, which subclasses
    use to define what happens when something comes in contact with the Trigger.

  Usage
  =====

    local triggerPart = workspace.TriggerPart
    local trigger = BaseTrigger.new(triggerPart)
    trigger:Connect()

  Because this class isn't supposed to be used on its own, any time triggerPart
  is touched you'll get an error because the default TouchListner() needs to be
  overidden in subclasses.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local Region = require(replicatedStorage.Region)

local BaseTrigger = {}
BaseTrigger.__index = BaseTrigger

function BaseTrigger.new(triggerPart)
  assert(triggerPart, "argument #1 must be a Part")

  local self = {}
  setmetatable(self, BaseTrigger)

  self.TriggerPart = triggerPart
  self.Region = Region.fromPart(triggerPart)

  return self
end

function BaseTrigger:TouchListner()
  error("You must override BaseTrigger's TouchListner method in subclasses.")
end

function BaseTrigger:Connect()
  self.TriggerPart.Touched:connect(function(otherPart)
    self:TouchListener(otherPart)
  end)
end

return BaseTrigger
