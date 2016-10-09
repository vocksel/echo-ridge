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

-- Makes sure the Component has a properly set ComponentType.
local function isComponentTypeSet(componentType, object)
  if componentType.Value ~= "" then
    return true
  else
    warn(string.format("%s is almost a Component, but its ComponentType "..
      "has not been set.", object:GetFullName()))
    return false
  end
end

-- Used with `find` to determine what Instances are Components.
local function isComponent(object)
  local componentType = object:FindFirstChild("ComponentType")
  if componentType and componentType:IsA("StringValue") then
    return isComponentTypeSet(componentType, object)
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

-- Finds the type of Component we're dealing with.
--
-- Because of how `find()` works, we have to get the ComponentType after we
-- collect all of the Components.
local function getComponentType(component)
  -- This function should always be called after all the Components are
  -- gathered, this ensures there's always a ComponentType to reference.
  return component.ComponentType.Value
end

-- Sorts all of the components into lists based off their ComponentType.
--
-- This keeps everything nice and organized, as if you have a ton of
-- "TriggerWarp" and "ActionWarp" Components, they'll each get their own table.
local function sortComponents(components)
  local sortedComponents = {}

  -- Creates a table for a ComponentType if it doesn't exist already.
  local function createComponentTable(componentType)
    if not sortedComponents[componentType] then
      sortedComponents[componentType] = {}
    end
    return sortedComponents[componentType]
  end

  for _, component in ipairs(components) do
    local componentType = getComponentType(component)
    local componentsList = createComponentTable(componentType)
    table.insert(componentsList, component)
  end

  return sortedComponents
end

-- Recurses through `parent` to get the list of all Components.
--
-- Returns a sorted list of all the components so they can be easily accessed
-- based off their ComponentType.
local function getComponents(parent)
  local function callback(object)
    return isComponent(object) and not isDisabled(object)
  end

  local components = find(parent, callback)

  return sortComponents(components)
end

--------------------------------------------------------------------------------

local componentLists = getComponents(COMPONENT_LOCATION)

function remotelyGetComponents.OnServerInvoke(_, componentType)
  return componentLists[componentType]
end
