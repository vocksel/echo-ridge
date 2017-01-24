local character = script.Parent
local humanoid = character:FindFirstChild("Humanoid")

local states = {
  -- Prevents the user from getting to places they shouldn't.
  Enum.HumanoidStateType.Jumping,

  -- Similar to jumping. We don't want the user to climb the models in the game
  -- to get somewhere they shouldn't.
  --
  -- Our models are fairly small-scale, too. We don't want the user to
  -- accidentally climb a table because of the part density.
  Enum.HumanoidStateType.Climbing
}

local function disableStates()
  for _, state in ipairs(states) do
    humanoid:SetStateEnabled(state, false)
  end
end

disableStates()
