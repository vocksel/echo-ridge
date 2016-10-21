-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local transmit = require(replicatedStorage.Events.Transmit)
local LocalCell = require(replicatedStorage.Level.LocalCell)
local LocalWorld = require(replicatedStorage.Level.LocalWorld)

local client = players.LocalPlayer

local function getCellModels()
  local getComponents = transmit.getRemoteFunction("GetComponents")
  return getComponents:InvokeServer("Cell")
end

local function getNewCell(cellModel)
  local cell = LocalCell.new(cellModel.Name)

  -- HACK This isn't a very clean way of setting the TimeOfDay of the Cell. For
  -- right now we really just need a TimeOfDay changing implementation, but this
  -- should be cleaned up as soon as possible.
  --
  -- See CellEntered connection in setupWorld() for related code.
  local timeOfDay = cellModel:FindFirstChild("TimeOfDay")
  if timeOfDay then
    cell.TimeOfDay = timeOfDay.Value
  end

  return cell
end

local function getCellsFromModels(cellModels)
  local cells = {}
  for _, cellModel in ipairs(cellModels) do
    table.insert(cells, getNewCell(cellModel))
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

  world.CellEntered:connect(function(cell)
    if cell.TimeOfDay then cell:UseTimeOfDay() end
  end)

  -- Start off in Geo's Room.
  world:EnterCell("GeosRoom")

  warpedToCell.Event:connect(function(cellModel)
    world:EnterCell(cellModel.Name)
  end)
end

setupWorld()
