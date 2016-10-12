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

local STORAGE_NAME = "TransmitStorage"
local STORAGE_PARENT = replicatedStorage

local function new(className, parent, name)
  local inst = Instance.new(className, parent)
  inst.Name = name or inst.Name
  return inst
end

local function getStorage()
  local storage = STORAGE_PARENT:FindFirstChild(STORAGE_NAME)
  return storage or new("Folder", STORAGE_PARENT, STORAGE_NAME)
end

local function getRemote(className, name)
  local storage = getStorage()
  local object = storage:FindFirstChild(name)
  return object or new(className, storage, name)
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
