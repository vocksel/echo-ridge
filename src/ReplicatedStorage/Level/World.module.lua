--[[
  World
  =====

  A World allows you to easily move Players between the Cells in your game
  without having to worry about leaving the last one they were in.

  Conceptually, a World can be thought of as the game itself, and the Cells it
  has access to are all the areas the Player can travel to.

  You should limit yourself to a single World instance, they're intended to be
  used to group all of the locations in your game, and as such there should be
  no case where you would need to work with more than one at a time.

  Constructors
  ------------

  World.new(table cells={})
    Creates a new World instance

    `cells` is a list of any Cell instances you want to immediately pass in. If
    you create all your Cells after defining the World instance, you can use
    AddCells instead.

  Properties
  ----------

  Cells (table)
    List of all the Cells that the instance of this class manages.

    If you need to add or remove a Cell from the list, use AddCell and
    RemoveCell, respectively.

  Methods
  -------

  Cell GetCellByName(string cellName)
    When you don't have a reference to a Cell, this method allows you to look
    one up by its Name.

  void AddCell(Cell cell)
    Adds `cell` to the list of Cells mamaged by this class.

  void RemoveCell(Cell/string cell)
    Removes `cell` from the list of Cells.

    `cell` can either be a direct reference to one of the Cells in `Cells`, or
    the name of one.

  Cell GetCurrentCell(Player player)
    Returns the Cell `player` is currently inside of.

    If `player` is not in a Cell, returns nil.

  void LeaveCurrentCell(Player player)
    Removes `player` from the Cell they're currently inside of.

    We don't have a method to explicitly leave one Cell, as each Player is only
    intended to be in one Cell at a time. This method is run automatically when
    calling EnterCell to ensure this.

    Because this method is run automatically, you typically won't need to use it
    unless you want to clear a Player out of all Cells indefinitely.

    Fires CellLeft.

  void EnterCell(Cell/string cell, Player player)
    Adds `player` to `cell`.

    This method calls LeaveCurrentCell so that `player` is only ever in one Cell
    at a time.

    `cell`, like with RemoveCell, can either be a Cell instance inside of the
    Cell list, or a string with one of their names.

    Fires CellEntered.

  Events
  ------

  CellEntered (Cell, Player)
    Fired when entering a Cell.

    Returns the Cell and the Player that entered the Cell.

  CellLeft (Cell, Player)
    Fired when a Player leaves a Cell.

    Returns the Cell and the Player that left the Cell.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local getIndexOfValue = require(replicatedStorage.Helpers.GetIndexOfValue)
local expect = require(replicatedStorage.Helpers.Expect)
local Signal = require(replicatedStorage.Events.Signal)
local Cell = require(script.Parent.Cell)

--------------------------------------------------------------------------------

local World = {}
World.__index = World

function World.new(cells)
  local self = {}
  setmetatable(self, World)

  self.Cells = cells or {}

  self.CellEntered = Signal.new()
  self.CellLeft = Signal.new()

  return self
end

function World:GetCellByName(cellName)
  for _, cell in ipairs(self.Cells) do
    if cell.Name == cellName then
      return cell
    end
  end
end

-- This is used so you can use either a string or a direct reference to a Cell.
function World:_GetByCellOrName(cell)
  expect(cell, { "Cell", "string" }, 1, "_GetByCellOrName")

  if type(cell) == "string" then
    return self:GetCellByName(cell)
  else
    return cell
  end
end

function World:AddCell(cell)
  expect(cell, { "Cell", "string" }, 1, "AddCell")

  table.insert(self.Cells, cell)
end

function World:RemoveCell(cell)
  expect(cell, { "Cell", "string" }, 1, "RemoveCell")

  cell = self:_GetByCellOrName(cell)

  local index = getIndexOfValue(cell, self.Cells)
  if index then
    table.remove(self.Cells, index)
  end
end

function World:GetCurrentCell(player)
  for _, cell in ipairs(self.Cells) do
    if cell:IsInCell(player) then
      return cell
    end
  end
end

function World:LeaveCurrentCell(player)
  local cell = self:GetCurrentCell(player)
  if cell then
    cell:Leave(player)
    self.CellLeft:fire(cell, player)
  end
end

function World:EnterCell(cell, player)
  expect(cell, { "Cell", "string" }, 1, "EnterCell")

  cell = self:_GetByCellOrName(cell)
  self:LeaveCurrentCell(player)
  cell:Enter(player)
  self.CellEntered:fire(cell, player)
end

return World
