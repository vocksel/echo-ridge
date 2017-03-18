--[[
  Cell
  ====

  Cells allow you to organize people depending on where they are in the game.

  If you have distinct areas such as an overworld, a house, and a dungeon, you
  can use Cells to keep track of which player is in which area.

  Cells are very open ended as they just let you organize players, but because
  of this you have a lot of options for what you can do with them.

  Constructors
  ------------

  Cell Cell.new(string name)
    Creates a new Cell named `name`.

  Properties
  ----------

  string Name
    The name of the Cell.

  table Players
    A list containing all the Players in the Cell.

  Methods
  -------

  bool Cell:IsInCell(Player player)
    Returns true if the Player is in this Cell, false otherwise.

  void Cell:Enter(Player player)
    Moves a Player into this Cell.

  void Cell:Leave(Player player)
    Removes a Player from this Cell.

  Events
  ------

  Player Entered
    Fired when a Player enters the Cell. Returns the entering Player.

  Player Left
    Fired when a Player leaves the Cell. Returns the leaving Player.

  Basic Usage
  -----------

  This example shows how you can move players between Cells. We'll be handling
  everything from the server, but Cells can just as easily be handled on the
  client.

    local players = game:GetService("Players")

    -- Start off by defining a couple Cells.
    local exterior = Cell.new("Exterior")
    local interior = Cell.new("Interior")

    -- This starts all the Players in the exterior of the game by default.
    players.PlayerAdded:connect(function(player)
      exterior:Enter(player)
    end)

    -- This will print out that we entered the Cell once we interact with the
    -- TeleportPad below.
    interior.Entered:connect(function(player)
    	print(player, "entered the interior Cell")
    end)

    -- From here you decide how the player is moved from one Cell to another.
    --
    -- In this example, we're going to use a Part to teleport them to another
    -- location, moving them into the Cell at the same time.

    workspace.TeleportPad.Touched:connect(function(otherPart)
      local humanoid = otherPart.Parent:FindFirstChild("Humanoid")
      if humanoid then
        local player = players:GetPlayerFromCharacter(otherPart.Parent)

        -- This would change the Player's position to move them to an interior
        -- location in the game.
        teleportToInterior(player)

        -- We start the Player off in the exterior Cell, so we have to make sure
        -- we leave it when entering another Cell.
        exterior:Leave(player)

        -- And finally we enter the interior Cell.
        interior:Enter(player)
      end
    end)

  Changing the Lighting
  ---------------------

  This example will show you how you can use Cells to locally change different
  properties, specifically those in the Lighting service.

  This should be in a LocalScript in StarterPlayerScripts to work properly.

    local lighting = game:GetService("Lighting")
    local players = game:GetService("Players")

    local overworld = Cell.new("Overworld")
    local dungeon = Cell.new("Dungeon")
    local client = players.LocalPlayer
    local character = client.Character or client.CharacterAdded:wait()

    overworld.Entered:connect(function()
      lighting.Ambient = Color3.fromRGB(0, 0, 0)
      lighting.Brightness = 1
      lighting.TimeOfDay = "14:00:00"
    end)

    dungeon.Entered:connect(function()
      lighting.Ambient = Color3.fromRGB(47, 47, 47)
      lighting.Brightness = .5
      lighting.TimeOfDay = "00:00:00"
    end)

    workspace.TeleportPad.Touched:connect(function(otherPart)
      if otherPart.Parent == character then
        overworld:Leave(client)
        dungeon:Enter(client)
      end
    end)
--]]


local replicatedStorage = game:GetService("ReplicatedStorage")

local expect = require(replicatedStorage.Helpers.Expect)
local getIndexOfValue = require(replicatedStorage.Helpers.GetIndexOfValue)
local Signal = require(replicatedStorage.Events.Signal)

--------------------------------------------------------------------------------

local Cell = {}
Cell.__index = Cell

function Cell.new(name)
  local self = {}
  setmetatable(self, Cell)

  assert(type(name) == "string", "You must supply a Name for your Cell.")

  self.Name = name
  self.Players = {}

  self.Entered = Signal.new()
  self.Left = Signal.new()

  return self
end

function Cell:__tostring()
  return self.Name
end

function Cell:IsInCell(player)
  assert(expect(player, "Player", 1, "IsInCell"))

  return getIndexOfValue(player, self.Players) and true or false
end

function Cell:Enter(player)
  assert(expect(player, "Player", 1, "Player"))

  table.insert(self.Players, player)
  self.Entered:fire(player)
end

function Cell:Leave(player)
  assert(expect(player, "Player", 1, "Leave"))

  local index = getIndexOfValue(player, self.Players)
  if index then
    table.remove(self.Players, index)
    self.Left:fire(player)
  end
end

return Cell
