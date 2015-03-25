-- Name: Client.Main
-- ClassName: LocalScript

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local animate = nevermore.LoadLibrary("Animate")

local function playAnimations()
  local terminal = workspace.SectionBottomLeft.Terminal
  local infoKiosk = workspace.SectionBottomLeft.InfoKiosk

  animate.terminalScreenLoop(terminal)
  animate.terminalButtonsLoop(terminal)
  animate.infoKiospLook(infoKiosk)
end

local function initialize()
  nevermore.ClearSplash()
end

initialize()
