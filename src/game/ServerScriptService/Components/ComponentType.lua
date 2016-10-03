--[[
  ComponentType
  =============

  A Component is an instance or collection of instances in the game that gets
  used in conjunction with other classes.

  For example, the Trigger class is instantiated with a specifically named Part
  with a ModuleScript inside of it. A ComponentType is used to find all
  Instances's in the game that match that criteria.

  Constructors
  ------------

  ComponentType.new(string remoteName, function callback)
    `remoteName` is the name of a RemoteFunction that will be used by the client
    to retrieve the `FoundComponents` property.

    `callback` determines what represents a Component. Whenever it returns true,
    the object that was passed into it will be considered a Component.

    For example, the following will make all Instances with a ModuleScript named
    "ComponentData" a Component in FoundComponents.

      local function callback(obj)
        local module = obj:FindFirstChild("ModuleScript")
        return module and module.Name == "ComponentData"
      end

      ComponentType.new("GetComponent", callback)

  Properties
  ----------

  self.Remote
    RemoteFunction named after `remoteName`.

    The OnServerInvoke function is automatically setup to return
    self.FoundComponents, so when the client runs InvokeServer() they will get
    the current list of Components.

  self.Callback
    Reference to the `callback` function.

  self.Location=workspace
    The location that will be recursed through when looking through Components.

    This can be changed to anything in the game, but should typically be a
    descendant of Workspace.

  self.FoundComponents={}
    List of all the Components that are found when `FindComponents()` is called.

  Methods
  -------

  FindComponents()
    Locates all of the Components.

    If any instance has a BoolValue named "Disabled" set to true, the instance
    will be ignored. This is used in development so we can add Components
    without them being picked up until we hook them up properly.

  GetComponents()
    This is used server-side for when we need to get the list of components.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local remotes = require(replicatedStorage.Events.Remotes)
local find = require(replicatedStorage.Util.Find)

-- This is used when finding Components. It allows us to skip instances that
-- have a Disabled BoolValue set to true.
local function isDisabled(obj)
  local disabled = obj:FindFirstChild("Disabled")
  if disabled and disabled:IsA("BoolValue") then
    return disabled.Value
  end
end

local ComponentType = {}
ComponentType.__index = ComponentType

function ComponentType.new(remoteName, callback)
  local self = {}
  setmetatable(self, ComponentType)

  self.Remote = remotes.getFunction(remoteName)
  self.Callback = callback

  self.Location = workspace
  self.FoundComponents = {}

  function self.Remote.OnServerInvoke()
    return self.FoundComponents
  end

  return self
end

function ComponentType:FindComponents()
  self.FoundComponents = find(self.Location, function(obj)
    return not isDisabled(obj) and self.Callback(obj)
  end)
end

function ComponentType:GetComponents()
  return self.FoundComponents
end

return ComponentType
