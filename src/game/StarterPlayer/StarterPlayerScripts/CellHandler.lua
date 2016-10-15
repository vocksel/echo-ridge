-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local transmit = require(replicatedStorage.Events.Transmit)
local Cell = require(replicatedStorage.Level.Cell)
local LocalWorld = require(replicatedStorage.Level.LocalWorld)

local client = players.LocalPlayer

local function getCellModels()
  local getComponents = transmit.getRemoteFunction("GetComponents")
  return getComponents:InvokeServer("Cell")
end

local function getCellsFromModels(cellModels)
  local cells = {}
  for _, cellModel in ipairs(cellModels) do
    table.insert(cells, Cell.new(cellModel.Name))
  end
  return cells
end

local function setupWorld()
  local cellModels = getCellModels()
  local cells = getCellsFromModels(cellModels)
  local world = LocalWorld.new(cells, client)

  -- Fired by StarterCharacterScripts.WarpListening. This lets us know when the
  -- client has been Warped to one of the Cell Models. From here we can perform
  -- the action to actually move them into the Cell.
  local warpedToCell = transmit.getLocalEvent("WarpedToCell")

  -- Start off in Geo's Room.
  world:EnterCell("GeosRoom")

  warpedToCell.Event:connect(function(cellModel)
    world:EnterCell(cellModel.Name)
  end)
end

setupWorld()
