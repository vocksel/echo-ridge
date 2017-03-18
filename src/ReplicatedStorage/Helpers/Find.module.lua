--[[
  Find
  ====

  Recursively searches for Instances that match a callback.

  This allows you to locate Instances in the game using complex search terms. It
  can also be used for a simple search if you only care about recursive searching.

  Parameters
  ----------

  parent (Instance)
    The starting point where you want to recursively locate Instances.

  callback (function)
    The callback used for matching.

    The Instance that `find` is currently processing is passed to this function.
    This is the only argument.

    An Instance is considered to be "found" if this function returns true.

  Usage
  -----

  To find all Parts in the game, you can simply do:

    local parts = find(workspace, function(child)
      return child:IsA("Part")
    end)

  Matches can use as many conditions as they like. If you want to find a very
  specific type of Instance, you can add on more conditions:

    local objects = find(workspace, function(child)
      return child:IsA("WedgePart") and child.Name == "Triangle" and
        child.BrickColor == BrickColor.new("Bright red")
    end)
--]]

local function find(parent, callback, found)
  local found = found or {}
  local children = parent:GetChildren()

  for _, child in ipairs(children) do
    if callback(child) then
      table.insert(found, child)
    end
    find(child, callback, found)
  end

  return found
end

return find
