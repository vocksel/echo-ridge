--[[
  GetIndexOfValue
  ===============

  Super simple helper function to get the index of a value in a table.

  This is primarily used in conjunction with table.remove, as we will sometimes
  know the value of an item, but not its index.

  This allows us to pass in the value, get the index, and then remove that value
  from the table.

  Note that this only works on index-value tables (arrays), not key-value
  (dictionaries).

  Usage
  -----

    local t = { "this", "table", "has", "a", "lot", "of", "values" }
    local index = getIndexOfValue("values", t)
    print(t[index] == "values") -- true
    table.remove(t, index)
    print(t[index] == nil) -- true
--]]

local function getIndexOfValue(value, list)
  for index, otherValue in ipairs(list) do
    if value == otherValue then
      return index
    end
  end
end

return getIndexOfValue
