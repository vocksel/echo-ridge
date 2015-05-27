--[[
  Stages are a way to group players that are in areas of your game.

  For example, you can create two stages, one for a town and another for a house
  in the town. Then you can move the player between the two stages:

    local player = game.Players.LocalPlayer

    local town = Stage.new("Town")
    local home = Stage.new("Home")

    -- "Town" is the starting stage, so you want to add the player there first
    town:AddPlayer(game.Players.LocalPlayer)

    -- Then later on your can move the player from one stage to another. This
    -- could be done when the player touches a part that teleports them.
    town:TransferPlayer(player, home)

  After the player has been transfered it's up to you what happens. This is
  purely a class for organizing the players.
--]]

local Stage = {}
Stage.__index = Stage

function Stage.new(name)
  local self = {}

  self.Name = name or "Unnamed"
  self.PlayerList = {}

  return setmetatable(self, Stage)
end

function Stage:__tostring()
  return self.Name
end

-- Gathers a list of Players currently in this stage.
--
-- This is exactly the same as you would use the GetPlayers method of the
-- Players service.
--
-- Returns a table containing a list of players in the stage.
function Stage:GetPlayers()
  return self.PlayerList
end

-- Add a Player to the stage.
function Stage:AddPlayer(player)
  table.insert(self.PlayerList, player)
end

-- Remove a Player from the Stage.
function Stage:RemovePlayer(player)
  -- Since we're dealing with an array, we have to get the index in the list of
  -- players before we can remove `player`.
  for index, playerInList in pairs(self.PlayerList) do
    if player == playerInList then
      table.remove(self.PlayerList, index)
    end
  end
end

-- Moves a Player from one stage to another.
--
-- player   - The Player to transfer.
-- newStage - The Stage to add the Player to.
function Stage:TransferPlayer(player, newStage)
  self:RemovePlayer(player)
  newStage:AddPlayer(player)
end

return Stage
