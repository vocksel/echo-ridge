--[[
  LocalWorld
  ==========

  This is an extension of the World class which works exclusively on the client.

  It can get annoying having to repeatedly pass in the client's Player when
  working with Worlds and Cells locally, which is where this class comes in.

  You simply pass in the client's Player when constructing and a reference to it
  is used for all the methods that need it.

  Constructors
  ------------

  LocalWorld.new(table cells, Player player)
    Same functionality as World, but with a new `player` argument to pass in the
    client's Player.
--]]

local World = require(script.Parent.World)

local LocalWorld = {}
LocalWorld.__index = LocalWorld
setmetatable(LocalWorld, World)

function LocalWorld.new(cells, player)
  local self = World.new(cells)
  setmetatable(self, LocalWorld)

  self.Client = player

  return self
end

function LocalWorld:GetCurrentCell()
  return World.GetCurrentCell(self, self.Client)
end

function LocalWorld:LeaveCurrentCell()
  return World.LeaveCurrentCell(self, self.Client)
end

function LocalWorld:EnterCell(cell)
  return World.EnterCell(self, cell, self.Client)
end

return LocalWorld
