--[[
  Worlds allow you to travel between all the Cells in your game.

  Cells by themselves have no way to transfer players between each other. That's
  what Worlds are for. They make it easy to move players between Cells.

  There is no way to travel between World instances, so you should limit
  yourself to one per game.
--]]

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local Signal = import("Signal")

local function cellHasPlayer(cell, player)
  local playerList = cell:GetPlayers()
  for _, playerInCell in ipairs(playerList) do
    if player == playerInCell then return true end
  end
  return false
end


--------------------------------------------------------------------------------
-- World
--------------------------------------------------------------------------------

local World = {}
World.__index = World

function World.new(cellList)
  local self = {}

  assert(cellList, "World.new() requires a table of Cell instances")

  -- A collection of Cell instances that the player can travel to.
  self.Cells = cellList

  -- Events
  self.CellEntered = Signal.new()
  self.CellLeft = Signal.new()

  return setmetatable(self, World)
end

function World:GetCurrentCell(player)
  for _, cell in ipairs(self.Cells) do
    if cellHasPlayer(cell, player) then
      return cell
    end
  end
end

function World:LeaveCell(cell, player)
  cell:Leave(player)
  self.CellLeft:fire(cell, player)
end

-- Used for transfering players between cells and when a player leaves the game.
function World:LeaveCurrentCell(player)
  local cell = self:GetCurrentCell(player)
  if cell then
    self:LeaveCell(cell, player)
  end
end

function World:EnterCell(cell, player)
  self:LeaveCurrentCell(player)
  cell:Enter(player)
  self.CellEntered:fire(cell, player)
end

return World
