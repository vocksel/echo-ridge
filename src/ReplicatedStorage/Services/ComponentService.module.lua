--[[
  ComponentService
  ==================

  Service for Component retrieval.

  A Componnet is an object in the game that you want to apply functionality to.

  To do this normally, you may find yourself putting Scripts into a Model, then
  copy/pasting the Model around the game. This is a bad practice, as when you
  want to update the functionality of the Model, you have to change the Scripts
  in each copy.

  When you define a Model as a Component, you can use this service to grab all
  Components of the same type, and apply the functionality on all of them from a
  single location.

  In essence, this system is just a way to tag and retrieve objects.

  Defining a Component
  --------------------

  Simply add a StringValue named "ComponentType" inside of an object in the
  game to turn it into a Component.

  The Value of ComponentType determines the type of Component it is. Component's
  with matching ComponentTypes are grouped together.

  Usage
  -----

  Say you're building an apartment. You have some light switches on the wall
  that you want to turn the lights in the apartment on and off.

  Instead of putting Scripts in each light switch to control them, you can add a
  ComponentType to each one. The Value could be "LightSwitch".

  Then you can use this service to gather up all the LightSwitch Components and
  apply functionality from one Script:

    local replicatedStorage = game:GetService("ReplicatedStorage")
    local components = require(replicatedStorage.Services.ComponentSevices)

    local lightSwitches = components:GetByType("LightSwitches")

    for _, lightSwitch in ipairs(lightSwitches) do
      -- What happens next is up to you.
    end
--]]

local run = game:GetService("RunService")

if run:IsServer() then
  local replicatedStorage = game:GetService("ReplicatedStorage")
  local serverStorage = game:GetService("ServerStorage")

  local ComponentLookup = require(serverStorage.Components.ComponentLookup)
  local expect = require(replicatedStorage.Helpers.Expect)

  local COMPONENT_LOCATION = workspace

  local function getLookup()
    local lookup = ComponentLookup.new()
    lookup:Propagate(COMPONENT_LOCATION)

    return lookup
  end

  local components = {
    lookup = getLookup()
  }

  function components:GetByType(componentType)
    assert(type(componentType) == "string", string.format("bad argument #1 to "..
      "GetByType (string expected, got %s)", expect.getType(componentType)))

    return self.lookup:GetComponents(componentType)
  end

  return components
else
  local route = require(script.Parent.Modules.Route)
  return route(script)
end
