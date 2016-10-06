--[[
  Region
  ======

  This is a simple wrapper for the Region3 class.

  The main benefits are the ability to run region operations from the instance
  itself, instead of having to go through the Workspace. It also lets you
  consturct a Region3 from a Part.

  Constructors
  ------------

  Region.new(Vector3 bottomPos, Vector3 topPos)
    Same as Region3.new. Constructs a new Region out of two Vector3s.

  Region.fromPart(Part part)
    Constructs a Region out of a Part's bounding box.

  Properties
  ----------

  The properties are the exact same as the Region3 class. Infact, they're just
  pointers to the internally constructed Region3.

  self.CFrame
    Position of the Region.
  self.Size
    Size of the Region.

  Methods
  -------

  PartIsInRegion(Part part)
    Checks if `part` is within the Region.

  CharacterIsInRegion(Model character)
    Check if a player's Character model is within the Region.

  Usage
  -----

    local region = Region.new(Vector3.new(1, 1, 1), Vector3.new(9, 9, 9))

    game.Players.PlayerAdded:connect(function(player)
      player.CharacterAdded:connect(function(character)
        while wait(.25) do

          if region:CharacterIsInRegion(chaarcter) then
            print(character.Name, "is inside the region")
          end

        end
      end)
    end)
--]]

local Region = {}
Region.__index = Region

-- Returns the bottom corner and opposite top corner on a part.
--
-- This is used for constructing a Region3 from a Part, as Region3.new() only
-- accepts two Vector3s.
local function getCorners(part)
	local pos = part.Position
	local halfSize = part.Size/2

	local bottomCorner = Vector3.new(pos.X - halfSize.X, pos.Y - halfSize.Y, pos.Z - halfSize.Z)
	local topCorner = Vector3.new(pos.X + halfSize.X, pos.Y + halfSize.Y, pos.Z + halfSize.Z)

	return bottomCorner, topCorner
end

function Region.new(bottomPos, topPos)
	local self = {}
	setmetatable(self, Region)

  local region = Region3.new(bottomPos, topPos)

  self._Region = region
  self.CFrame = region.CFrame
  self.Size = region.Size

	return self
end

function Region.fromPart(part)
	local bottomCorner, topCorner = getCorners(part)
	return Region.new(bottomCorner, topCorner)
end

function Region:__tostring()
  return tostring(self._Region)
end

function Region:PartIsInRegion(part)
	local parts = workspace:FindPartsInRegion3(self._Region, nil, math.huge)
	for _, partInRegion in ipairs(parts) do
		if part == partInRegion then
			return true
		end
	end
	return false
end

function Region:CharacterIsInRegion(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		return self:PartIsInRegion(rootPart)
	end
end

return Region
