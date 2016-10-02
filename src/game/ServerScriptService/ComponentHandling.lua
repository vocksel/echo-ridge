--[[
  ComponentManager
  ================

  Handles the retrieval of Components.

  A Component, while not having a class, is what we call an Instance or group of
  Instances in the game, and are used in conjunction with other classes.

  For example, we collect all Parts with a TriggerData ModuleScript so that only
  specifically setup Parts will be used to instantiate new Trigger classes.

  For the Future
  --------------

  This Script handles the gathering of all the Components for the client, but
  right now the client has the freedom to turn anything in the game into any of
  the available classes in ReplicatedStorage.

  Eventually we'll be counteracting this, by making the server the authority
  figure, where all of the Components it gathers are the only Instances that the
  client can work with.

  When these countermeasures are implemented, if the client (for example)
  attempts to turn a TriggerPart into a Warp, the server will check the
  TriggerPart against the list of Warp Components. If it's not in the list,
  we'll repremand the client. This will come in the form of either rolling back
  the changes they made, kicking them from the server, or something similar.
--]]

local serverScripts = game:GetService("ServerScriptService")

local ComponentType = require(serverScripts.Components.ComponentType)

--[[
  Gets all of the Parts for Trigger classes (TriggerParts).
--]]
local trigger = ComponentType.new("GetTriggerParts", function(obj)
  return obj:FindFirstChild("TriggerData")
end)

--[[
  Gets all of the Models for Warp classes (WarpModels).

  For something to be considered a Warp it must be a Model and have "Warp" at
  the end of its name.

  A WarpModel can contain the following instances:

  - BasePart named "Pad" (required).
  - ObjectValue named "LinkedWarp". The Value property points to another Warp.
  - Part named "Trigger"
--]]
local warp = ComponentType.new("GetWarpModels", function(obj)
  return obj:IsA("Model") and obj.Name:match("Warp$")
end)

for _, componentType in ipairs{ trigger, warp } do
  componentType:FindComponents()
end
