--[[
  RegionTrigger
  -------------

  TouchEnded detection in the form of Region3s. Inherits Trigger.

  When using this class you'll typically want to add Parts to the Whitelist so
  only specific Parts will start up the Region loop.

  If you're looking for Region detection for a Player's Character, check out
  CharacterTrigger.

  Constructors
  ------------

  RegionTrigger.new(Part triggerPart)
    This is the same as Trigger.new().

  Properties
  ----------

  Heartbeat
    This is a Heartbeat instance that is used to check for Parts leaving the
    Region.

    This is used internally and is not intended for public use.

  Region
    This is a Region instance that is constructed from TriggerPart.

    It's used to detect with a Part leaves the area of the TriggerPart.

    Using Region3s comes with the downside of not being able to rotate the
    TriggerPart, but it's a small price to pay for built-in area detection.

  Methods
  -------

  DetectTouchEnded(otherPart)
    Fires TouchEnded when `otherPart` leaves the Region.

  HandleTouch(otherPart)
    This works the same as Trigger:HandleTouch(), but it also starts up the
    Heartbeat loop to run DetectTouchEnded().

  Events
  ------

  TouchEnded
    Fired when a Part leaves the Region.

    If there are items in the whitelist, this will only fire if the Part is in
    there too.
--]]

local run = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local Heartbeat = require(replicatedStorage.Events.Heartbeat)
local Region = require(replicatedStorage.Region)
local Signal = require(replicatedStorage.Events.Signal)
local Trigger = require(script.Parent.Trigger)

--------------------------------------------------------------------------------

local RegionTrigger = {}
RegionTrigger.__index = RegionTrigger
setmetatable(RegionTrigger, Trigger)

function RegionTrigger.new(triggerPart)
  local self = Trigger.new(triggerPart)
  setmetatable(self, RegionTrigger)

  self.Heartbeat = Heartbeat.new()
  self.Region = Region.fromPart(triggerPart)

  self.TouchEnded = Signal.new()

  return self
end

function RegionTrigger:DetectTouchEnded(otherPart)
  if not self.Region:PartIsInRegion(otherPart) then
    self.TouchEnded:fire(otherPart)
    return true
  end
end

function RegionTrigger:HandleTouch(otherPart)
  Trigger.HandleTouch(self, otherPart)

  self.Heartbeat:AddCallback(function()
    return self:DetectTouchEnded(otherPart)
  end)
end

return RegionTrigger
