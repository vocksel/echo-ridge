--[[
  Transmit
  ========

  Used for making server-client and cross-script communication easy.

  This module takes care of managing the location of all your transmission
  objects (remote/bindable event/function) and allows you to access them quickly
  and easily.

  Functions
  ---------

  Each one of these functions takes a `name` parameter, which determines the
  name of the transmission object you're generating.

  If the transmission object does not exist, it will be created. This means you
  use the same syntax across all Scripts.

  transmit.getLocalEvent(string name)
  transmit.getLocalFunction(string name)
  transmit.getRemoteEvent(string name)
  transmit.getRemoteFunction(string name)

  Usage
  -----

    -- Server
    local event = transmit.getRemoteEvent("ServerMessage")

    event:FireAllClients("Greetings from the server!")

    -- Client
    local event = transmit.getRemoteEvent("ServerMessage")

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

local function getTransmissionObject(className, name)
  assert(type(name) == "string", "Please specify a name for the transmit "..
    "object.")

  local storage = getStorage()
  local object = storage:FindFirstChild(name)
  return object or new(className, storage, name)
end

--------------------------------------------------------------------------------

function transmit.getLocalEvent(name)
  return getTransmissionObject("BindableEvent", name)
end

function transmit.getLocalFunction(name)
  return getTransmissionObject("BindableFunction", name)
end

function transmit.getRemoteEvent(name)
  return getTransmissionObject("RemoteEvent", name)
end

function transmit.getRemoteFunction(name)
  return getTransmissionObject("RemoteFunction", name)
end

return transmit
