--[[
  CharacterTrigger
  ================

  Trigger for Character detection. Inherits RegionTrigger.

  This is typically used by the client so that they can detect when their
  Character is inside one of the Trigger Parts.

  The client can then bind actions while inside of the trigger so they can
  interact with the world.

  Connstructors
  -------------

  CharacterTrigger.new(Part triggerPart, Model character)
    Creates a new CharacterTrigger.

    `triggerPart` is the Part it used to determine the area of the trigger.

    `character` is the Character, and is the only one that's allowed to interact
    with the TriggerPart.
--]]

local RegionTrigger = require(script.Parent.RegionTrigger)

local CharacterTrigger = {}
CharacterTrigger.__index = CharacterTrigger
setmetatable(CharacterTrigger, RegionTrigger)

function CharacterTrigger.new(triggerPart, character)
  local self = RegionTrigger.new(triggerPart)
  setmetatable(self, CharacterTrigger)

  local rootPart = character:FindFirstChild("HumanoidRootPart")
  self.Whitelist:Add(rootPart)

  return self
end

return CharacterTrigger
