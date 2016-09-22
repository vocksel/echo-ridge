--[[
  Recurses through `parent`, running `callback` on the children.

  An item is considered to be "found" if `callback` returns true. For example,
  if you want to find all Instances with a "Configuration":

    local instances = find(workspace, function(child)
      return child:FindFirstChild("Configuration")
    end)

  `instances` will now be a table of all the instances in Workspace that have a
  Configuration inside of them.
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
