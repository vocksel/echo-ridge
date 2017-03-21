--[[
  Array
  =====

  Dedicated class for index-based tables.

  Lua does not make a distinction between arrays and dictionaries. A table can
  be both. This class is used to solidify the concept of an array, and comes
  with some helpful methods.

  Constructors
  ------------

  Array.new(table items={})
    Creates a new Array, filled with `items`.

  Properties
  ----------

  Items (table)
    Holds all of the items in the Array.

    Use Add() and Remove() instead of accessing this directly.

  Methods
  -------

  IsEmpty()
    Returns true if there are any entries in self.Items. False otherwise.

  Add(value)
    Adds `value` to self.Items.

    `value` can be anything: a ROBLOX instance, a table, a string, it doesn't
    matter.

  Remove(value)
    Removes `value` from self.Items.

  Has(value)
    Returns true if `value` exists inside of self.Items. False otherwise.

  Usage
  -----

    local array = Array.new()

    print(array:IsEmpty()) -- true

    list:Add("String")

    print(array:IsEmpty()) -- false
    print(array:Has("String")) -- true

    local function hello(name)
      return string.format("Hello %s!", name or "World")
    end

    array:Add(hello)
    print(array:Has(hello)) -- true

    array:Remove(hello)
    print(array:Has(hello)) -- false
--]]

local getIndexOfValue = require(script.Parent.GetIndexOfValue)

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
  if self:Has(value) then
    local index = getIndexOfValue(value, self.Items)
    table.remove(self.Items, index)
  end
end

function Array:Has(value)
  return getIndexOfValue(value, self.Items) and true or false
end

return Array
