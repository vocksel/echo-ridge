--[[
  Temporarily enables players to jump when they're seated.

  Seats only allow you to stand up from them by jumping. Because we disable
  jumping globally in the DisableStates script, this means that when a player
  sits, they can never get back up.

  This script overrides the global behavior and allows the player to stand up
  after they've been seated.
--]]

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local function allowJumping(newState)
  humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, newState)
end

humanoid.Seated:connect(function(isSeated)
  if isSeated then
    allowJumping(true)
  else
    allowJumping(false)
  end
end)
