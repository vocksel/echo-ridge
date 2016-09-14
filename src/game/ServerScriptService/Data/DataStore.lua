--[[
  A very simple wrapper for the DataStore methods.

  Do you ever find yourself typing the word "Async" over and over again every
  time you work with DataStores? There's got to be a better way!

  Well now there is! With this simple module you will never need to type the
  word "Async" again. Thaaat's right, for the low price of FREE you can save
  yourself from the pain of remembering the correct sequence of letters to type
  that horrible word.

  Also with Crazyman32's MockDataStoreService module, all data store operations
  can be handled offline. Now your game won't break down and cry when testing
  locally.
--]]

local dataStoreService = game:GetService("DataStoreService")

if game.PlaceId == 0 then
  dataStoreService = require(script.Parent.MockDataStoreService)
end

local DataStore = {}
DataStore.__index = DataStore

function DataStore.new(name, scope)
  local self = {}

  self.DataStore = dataStoreService:GetDataStore(name, scope)

  return setmetatable(self, DataStore)
end

function DataStore:Get(key)
  self.DataStore:GetAsync(key)
end

function DataStore:Set(key, value)
  self.DataStore:SetAsync(key, value)
end

function DataStore:Update(key, callback)
  self.DataStore:UpdateAsync(key, callback)
end

function DataStore:Increment(key, delta)
  self.DataStore:IncrementAsync(key, delta)
end

return DataStore
