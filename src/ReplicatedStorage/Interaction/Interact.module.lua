--[[
  Interact
  ========

  Primary class for all game-based user interaction.

  When we want the player to be prompted to interact with the game world, this
  is the class we use.

  It's just a simple Action class, but it predefines all of the input types for
  us, so we just need to instantiate a new Interact whenever we want the user to
  be able to do something.

  Constructors
  ============

  Interact.new()
    Simply creates a new Interact instance that has a pre-configured name and
    keybinds. Everything else is inherited from Action.

  Usage
  =====

  local interact = Interact.new()

  interact:SetBoundFunction(function(inputState)
    if inputState == Enum.UserInputState.End then return end
    print("Hello, World!")
  end)
--]]

local Action = require(script.Parent.Action)

-- Mobile automatically gets a button, we only need to bind keybaord and
-- controller inputs.
local INPUTS = {
  Enum.KeyCode.E, -- Keyboard
  Enum.KeyCode.ButtonA -- Gamepad
}

local Interact = {}
Interact.__index = Interact
setmetatable(Interact, Action)

function Interact.new()
  local self = Action.new("Interact", INPUTS)
  self.UseMobileButton = true

  return setmetatable(self, Interact)
end

return Interact
