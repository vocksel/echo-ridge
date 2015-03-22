--[[
  A very simple wrapper for the DataStore methods.

  Do you ever find yourself typing the word "Async" over and over again every
  time you work with DataStores? There's got to be a better way!

  Well now there is! With this simple module you will never need to type the
  word "Async" again. Thaaat's right, for the low price of FREE you can save
  yourself from the pain of remembering the correct sequence of letters to type
  that horrible word.

  Also with Crazyman32's MockDataStoreService module,d all data store operations
  can be handled offline. Now your game won't break down and cry when testing
  locally.
--]]

local dataStoreService = game:GetService("DataStoreService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))

local data = {}

if game.PlaceId == 0 then
  dataStoreService = nevermore.LoadLibrary("MockDataStoreService")
end

function data.getDataStore(name, scope)
  return dataStoreService:GetDataStore(name, scope)
end

function data.get(dataStore, key)
  return dataStore:GetAsync(key)
end

function data.set(dataStore, key, value)
  dataStore:SetAsync(key, value)
end

function data.update(dataStore, key, callback)
  dataStore:UpdateAsync(key, callback)
end

function data.increment(dataStore, key, delta)
  dataStore:IncrementAsync(key, delta)
end

return data
