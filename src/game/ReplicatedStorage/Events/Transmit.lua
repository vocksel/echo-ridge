--[[
  Simple module for getting RemoteEvents and RemoteFunctions.

  It takes care of managing the location of your remotes and allows you to
  access them quickly and easily.

  Usage:

    -- Server
    local transmit = require(game.ReplicatedStorage.Remotes)
    local event = transmit.getEvent("ServerMessage")

    event:FireAllClients("Greetings from the server!")

    -- Client
    local transmit = require(game.ReplicatedStorage.Remotes)
    local event = transmit.getEvent("ServerMessage")

    event.OnClientEvent:connect(function(msg)
      print(msg) -- "Greetings from the server!"
    end)
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local transmit = {}

local STORAGE_NAME = "RemoteStorage"
local STORAGE_PARENT = replicatedStorage

local function new(className, parent, name)
  local inst = Instance.new(className, parent)
  inst.Name = name or inst.Name
  return inst
end

local function getStorage()
  local storage = STORAGE_PARENT:FindFirstChild(STORAGE_NAME)

  if not storage then
    return new("Folder", STORAGE_PARENT, STORAGE_NAME)
  else
    return storage
  end
end

local function getRemote(className, name)
  local storage = getStorage()
  local remote = storage:FindFirstChild(name)

  if not remote then
    return new(className, storage, name)
  else
    return remote
  end
end

--------------------------------------------------------------------------------

function transmit.getEvent(name)
  assert(type(name) == "string", "Please specify a name for your RemoteEvent.")
  return getRemote("RemoteEvent", name)
end

function transmit.getFunction(name)
  assert(type(name) == "string", "Please specify a name for your RemoteFunction.")
  return getRemote("RemoteFunction", name)
end

return transmit
