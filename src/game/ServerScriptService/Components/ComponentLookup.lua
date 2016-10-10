--[[
  ComponentLookup
  ===============

  The backbone of the ComponentDiscovery Script, which handles the actual
  discovery of Components.

  Usage
  -----

  local lookup = ComponentLookup.new()
  lookup:Propagate(workspace)

  local warps = lookup:GetComponents("Warp")

  for _, warpModel in ipairs(warps) do
    print(warpModel:GetFullName())
  end

  Constructors
  ------------

  ComponentLookup.new()
    This doesn't do much on its own. You need to call the Propagate() method to
    gather the Components.

  Properties
  ----------

  Components (table)
    This is a flat list of every Component in the game.

    Generally you won't need to access this, instead use the GroupedComponents
    list.

    This is used when you don't need to worry about the ComponentType of a
    Component and you just need to look through the list of all of them.

  GroupedComponents (table)
    A grouped list of Components.

    Instead of referencing this directly, use GetComponents().

    Each type of Component is grouped in a sub-table, so if you want to access
    all the Warp Components you would use:

      local lookup = ComponentLookup.new()
      lookup:Propagate()

      local warps = lookup.GroupedComponents["Warp"]

  Methods
  -------

  Propagate(Instance parent)
    This method collects all of the Components in the game.

    After calling this, use GetComponents() to get the Components you want to
    work with.

    This method handles the initial discovery of Components by propagating the
    Components and GroupedComponents properties.

  GetComponents(string componentType)
    Gets all of the Components that have a ComponentType matching
    `componentType`.

  GetSubComponents(Instance parent, string componentType)
    Locations all of the Components under `parent`.

    If `componentType` is supplied, only Components that have a matching
    ComponentType will be returned.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local find = require(replicatedStorage.Helpers.Find)

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
local function sortComponents(components)
  local sortedComponents = {}

  for _, component in ipairs(components) do
    local group = getSubTable(sortedComponents, getComponentType(component))
    table.insert(group, component)
  end

  return sortedComponents
end

--------------------------------------------------------------------------------

local ComponentLookup = {}
ComponentLookup.__index = ComponentLookup

function ComponentLookup.new()
  local self = {}
  setmetatable(self, ComponentLookup)

  self.Components = {}
  self.GroupedComponentss = {}

  return self
end

function ComponentLookup:Propagate(parent)
  local components = find(parent, function(child)
    return getComponentType(child) and not isDisabled(child)
  end)

  self.Components = components
  self.GroupedComponents = sortComponents(self.Components)
end

function ComponentLookup:GetComponents(componentType)
  return self.GroupedComponents[componentType]
end

function ComponentLookup:GetSubComponents(parent, componentType)
  local subComponents = {}
  local components = self.Components

  if componentType then
    components = self.GroupedComponents[componentType]
  end

  for _, component in ipairs(components) do
    if component:IsDescendantOf(parent) then
      table.insert(subComponents, component)
    end
  end

  return subComponents
end

return ComponentLookup
