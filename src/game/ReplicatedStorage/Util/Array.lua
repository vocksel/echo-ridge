--[[
  Array
  =====

  Class to make working with index-key tables easier.

  This is intended for use as a whitelist for the Trigger classes so that we
  only detect certain Parts.

  Constructors
  ------------

  Array.new(table items)
    Creates a new Array with `items` as the default for self.Items.

    If not supplied, `items` defaults to an empty table.

  Properties
  ----------

  Items (table)
    Holds all of the items in the Array. You should use Add() and Remove()
    instead of accessing this directly.

  Methods
  -------

  IsEmpty()
    Checks if the Array has any items or not.

  Add(value)
    Adds `value` to self.Items.

    `value` can be anything: a ROBLOX instance, a table, a string, it doesn't
    matter.

  Remove(value)
    Removes `value` from self.Items.

  Has(value)
    Checks if `value` exists inside of self.Items.

  Usage
  -----

    local list = Array.new()

    print(list:IsEmpty()) -- true

    list:Add("String")

    print(list:Has("String")) -- true

    local function hello(name)
      return string.format("Hello %s!", name or "World")
    end

    list:Add(hello)
    print(list:Has(hello)) -- true

    list:Remove(hello)
    print(list:Has(hello)) -- false

    print(list:IsEmpty()) -- false
--]]

local function getIndexOfValue(value, list)
  for index, otherValue in ipairs(list) do
    if value == otherValue then
      return index
    end
  end
end

local Array = {}
Array.__index = Array

function Array.new(defaultItems)
  local self = {}
  setmetatable(self, Array)

  self.Items = defaultItems or {}

  return self
end

function Array:IsEmpty()
  return #self.Items == 0
end

function Array:Add(value)
  table.insert(self.Items, value)
end

function Array:Remove(value)
  local index = getIndexOfValue(value, self.Items)
  table.remove(self.Items, index)
end

function Array:Has(value)
  local index = getIndexOfValue(value, self.Items)
  return (index and self.Items[index]) and true or false
end

return Array
