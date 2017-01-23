--[[
  LocalCell
  =========

  An extension of the Cell class, used for modifying properties of the Client
  when entering Cells.

  We use this a lot to change the TimeOfDay when going between Echo Ridge and
  interior Cells. The TimeOfDay is specficially tuned for Echo Ridge and doesn't
  look very good with interiors.

  Methods
  -------

  SetTime(string newTime)
    Sets the client's TimeOfDay.

    `newTime` must be a string representation of a 24-hour clock.
--]]

local lighting = game:GetService("Lighting")

local Cell = require(script.Parent.Cell)

local LocalCell = {}
LocalCell.__index = LocalCell
setmetatable(LocalCell, Cell)

function LocalCell.new(name)
  local self = Cell.new(name)
  setmetatable(self, LocalCell)

  self.TimeOfDay = nil

  return self
end

function LocalCell:UseTimeOfDay(newTime)
  lighting.TimeOfDay = self.TimeOfDay
end

return LocalCell
