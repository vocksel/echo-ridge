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

  Methods
  -------

  IsEmpty()
    Returns true if there are any entries in the array. False otherwise.

  Has(value)
    Returns true if `value` exists inside of the array. False otherwise.

  Add(value)
    Adds `value` to self._Items.

  Remove(value)
    Removes `value` from the array.

  Find(callback)
    Returns the value of the first item in the Array that satisfies the
    provided callback.

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

  self._Items = defaultItems or {}

  return self
end

function Array:IsEmpty()
  return #self._Items == 0
end

function Array:Add(value)
  table.insert(self._Items, value)
end

function Array:Remove(value)
  if self:Has(value) then
    local index = getIndexOfValue(value, self._Items)
    table.remove(self._Items, index)
  end
end

function Array:Has(value)
  return getIndexOfValue(value, self._Items) and true or false
end

function Array:Find(callback)
  for _, item in ipairs(self._Items) do
    if callback(item) then
      return item
    end
  end
end

return Array
