--[[
  Collects all of the Parts for Trigger instances.

  A Trigger is a class that takes in a Part. The Part represents an area in the
  game world that the user can perform an action from. For example, a Trigger is
  placed in front of the Wave Station. While your character is inside the
  Trigger, you can press a key to enter the Wave World.

  This script is used to gather up all of those Parts so that the client can
  request them and instatiate new Triggers.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = require(replicatedStorage.Events.Remotes)

-- This is where we'll recurse through to look for triggers.
local TRIGGER_LOCATION = workspace

-- This allows the client to get the current list of triggers so they can hook
-- up the touch events.
--
-- From there, everything is handled by the server letting the client know when
-- triggers are added/removed, and then connecting touched events.
local remotelyGetTriggers = remotes.getFunction("GetTriggerParts")

--------------------------------------------------------------------------------

--[[
  Recurses through `parent`, running `callback` on the children.

  An item is considered to be "found" if `callback` returns true. For example,
  if you want to find all Instances with a "Configuration":

    local instances = find(workspace, function(child)
      return child:FindFirstChild("Configuration")
    end)

  `instances` will now be a table of all the instances in Workspace that have a
  Configuration inside of them.
--]]
local function find(parent, callback, found)
  local children = parent:GetChildren()
  local found = found or {}
  for _, child in ipairs(children) do
    if callback(child) then
      table.insert(found, child)
    end
    find(child, callback, found)
  end
  return found
end

local function isTriggerPart(part)
  return part:FindFirstChild("TriggerData")
end

local function getTriggerParts()
  return find(TRIGGER_LOCATION, isTriggerPart)
end

local function init()
  local triggerParts = getTriggerParts()

  function remotelyGetTriggers.OnServerInvoke()
    return triggerParts
  end
end

init()
