--[[
  Heartbeat
  =========

  A wrapper class for the Heartbeat event.

  This class allows you to start and stop a Heartbeat, along with adding
  callbacks to be run in the loop.

  When a callback is added, the loop starts. When all callbacks finish, the loop
  stops.

  This class saves a lot on performance, as instead of creating a new Heartbeat
  connection each time you need to run a loop, you can add a callback to a main
  loop that will be run in tandem with other callbacks. One loop, multiple
  operations.

  Constructors
  ------------

  Heartbeat.new()
    Returns a new Heartbeat.

    You need to run AddCallback(), which will automatically start the loop if it
    wasn't already running.

  Properties
  ----------

  Callbacks (table)
    Contains all of the callbacks.

    You should not access this directly, instead use AddCallback() and
    RemoveCallback().

  Connection
    Holds the Heartbeat's `Connection` object.

    You should not access this directly, instead use Start() and Stop().

  Methods
  -------

  IsRunning()
    Checks if the loop is currently running.

  HasCallbacks()
    Checks if there are any callbacks currently registered.

  AddCallback(function callback)
    Adds a callback that will be run every time the Heartbeat fires.

    If loop is not running, this method will start the loop for you.

    If `callback` returns `true`, it's considered to be finished and will be
    removed from the list of callbacks.

  RemoveCallback(function callback)
    Removes a callback from the list.

    If the loop is running, when this removes the last callback the loop is
    stopped.

    Callbacks are automatically removed when they've finished running.

  Start()
    Starts the loop.

    Calling this method when a loop is already running will output a warning to
    the console.

  Stop()
    Stops the loop.
--]]

local run = game:GetService("RunService")

-- Used to determine how many callbacks we have registered.
local function getDictLength(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

local Heartbeat = {}
Heartbeat.__index = Heartbeat

function Heartbeat.new(callback)
  local self = {}
  setmetatable(self, Heartbeat)

  self.Callbacks = {}
  self.Connection = nil

  return self
end

function Heartbeat:IsRunning()
  return self.Connection and self.Connection.connected
end

function Heartbeat:HasCallbacks()
  return getDictLength(self.Callbacks) > 0
end

function Heartbeat:AddCallback(callback)
  self.Callbacks[callback] = true

  if not self:IsRunning() then
    self:Start()
  end
end

function Heartbeat:RemoveCallback(callback)
  self.Callbacks[callback] = nil

  if not self:HasCallbacks() then
    self:Stop()
  end
end

-- Runs one of the callbacks.
--
-- Removes the callback if it returns `true`.
function Heartbeat:_RunCallback(callback)
  local done = callback()
  if done then self:RemoveCallback(callback) end
end

-- Runs all of the callbacks at once.
function Heartbeat:_RunCallbacks()
  for callback in pairs(self.Callbacks) do
    self:_RunCallback(callback)
  end
end

function Heartbeat:Start()
  if self:IsRunning() then
    warn("You can only run one loop at a time with the Heartbeat class")
  else
    self.Connection = run.Heartbeat:connect(function()
      self:_RunCallbacks()
    end)
  end
end

function Heartbeat:Stop()
  if self:IsRunning() then
    self.Connection:disconnect()
  end
end

return Heartbeat
