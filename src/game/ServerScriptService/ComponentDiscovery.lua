--[[
  ComponentDiscovery
  ==================

  Handles the discovery of "Components".

  A Component is what we call an Instance (or group of Instances) in the game
  that are used in conjunction with other classes.

  Components are currently only used client-side, but in the future this will be
  changed to allow the server more control. (See "For the Future" below)

  Defining a Component
  --------------------

  A Component is any Instance that has a StringValue named "ComponentType". The
  Value determines the name of the Component.

  Components with the same ComponentType will be grouped together for easy
  accessibility.

  Usage
  -----

  Say you're building an apartment and you want to light switches to turn the
  lights on and off.

  Instead of putting Scripts in each light switch to control them, you can add a
  ComponentType to each one. The Value could be "LightSwitch".

  Now that you have all your Components setup, you can create a single Script to
  manage them all:

    local replicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = require(replicatedStorage.Event.Remotes)
    local getComponents = remotes.getFunction("GetComponents")

    local lightSwitches = getComponents:InvokeServer("LightSwitches")

    for _, lightSwitch in ipairs(lightSwitches) do
      -- What happens next is up to you.
    end

  For the Future
  --------------

  This Script handles the gathering of all the Components for the client, but
  right now the client has the freedom to turn anything in the game into any of
  the available classes in ReplicatedStorage.

  Eventually we'll be counteracting this by making the server the authority
  figure, where all of the Components it gathers are the only Instances that the
  client can work with.

  When these countermeasures are implemented, if the client (for example)
  attempts to turn a TriggerPart into a Warp, the server will check the
  TriggerPart against the list of Warp Components. If it's not in the list,
  we'll repremand the client. This will come in the form of either rolling back
  the changes they made, kicking them from the server, or something similar.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local COMPONENT_LOCATION = workspace

local remotes = require(replicatedStorage.Events.Remotes)
local find = require(replicatedStorage.Helpers.Find)

local remotelyGetComponents = remotes.getFunction("GetComponents")

-- Used when grouping Components together to create the ComponentType sub-tables.
local function getSubTable(t, name)
  if not t[name] then
    t[name] = {}
  end
  return t[name]
end

-- Gets the ComponentType of an object (if it exists).
--
-- This gets used to simply get the ComponentType, along with being used with
-- `find()` to locate all of the Components in the game.
--
-- It also makes sure any ComponentType it comes across has been set properly.
local function getComponentType(object)
  local componentType = object:FindFirstChild("ComponentType")

  if componentType and componentType:IsA("StringValue") then
    assert(componentType.Value ~= "", string.format("Value for '%s' not set",
      componentType:GetFullName()))

    return componentType.Value
  end
end

-- Allows Components to be disabled.
--
-- If there's a BoolValue named "Disabled" set to true inside of a Component,
-- the Component will be excluded from the final list.
--
-- This allows us to develop new Components without them being picked up
-- immediately so we don't go and break everything.
local function isDisabled(object)
  local disabled = object:FindFirstChild("Disabled")
  if disabled and disabled:IsA("BoolValue") then
    return disabled.Value
  end
end

-- Sorts all of the components into lists based off their ComponentType.
--
-- This keeps everything nice and organized, as if you have a ton of
-- "TriggerWarp" and "ActionWarp" Components, they'll each get their own table.
local function groupComponents(components)
  local sortedComponents = {}

  for _, component in ipairs(components) do
    local group = getSubTable(sortedComponents, getComponentType(component))
    table.insert(group, component)
  end

  return sortedComponents
end

-- Recurses through `parent` to get the list of all Components.
--
-- Returns a sorted list of all the components so they can be easily accessed
-- based off their ComponentType.
local function getAllComponents(parent)
  return find(parent, function(object)
    return getComponentType(object) and not isDisabled(object)
  end)
end

local function getGroupedComponents(parent)
  local components = getAllComponents(parent)
  return groupComponents(components)
end

--------------------------------------------------------------------------------

local componentLists = getGroupedComponents(COMPONENT_LOCATION)

function remotelyGetComponents.OnServerInvoke(_, componentType)
  return componentLists[componentType]
end
