--[[
  This class gets its name from "Cells" in Bathesda titles. Any interior zone in
  Skyrim, be it a house or a dungeon, is considered a Cell.

  The only difference between Bathesda Cells and this class is that any area in
  the game you can travel to can be a Cell, not just interiors.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local import = nevermore.LoadLibrary

local Signal = import("Signal")

local Cell = {}
Cell.__index = Cell

function Cell.new(name)
  local self = {}

  self.Name = name or "Cell"
  self.PlayerList = {}

  self.Entered = Signal.new()
  self.Left = Signal.new()

  return setmetatable(self, Cell)
end

function Cell:__tostring()
  return self.Name
end

-- Gathers a list of Players currently in this Cell.
--
-- This is exactly the same as you would use the GetPlayers method of the
-- Players service.
function Cell:GetPlayers()
  return self.PlayerList
end

function Cell:Leave(player)
  -- Since we're dealing with an array, we have to get the index in the list of
  -- players before we can remove `player`.
  for index, playerInList in pairs(self.PlayerList) do
    if player == playerInList then
      table.remove(self.PlayerList, index)
      self.Left:fire()
      break
    end
  end
end

function Cell:Enter(player)
  table.insert(self.PlayerList, player)
  self.Entered:fire()
end

return Cell
