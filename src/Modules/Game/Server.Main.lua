-- Name: Server.Main
-- ClassName: Script

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local animate = nevermore.LoadLibrary("Animate")

local function runContinuousAnimations()
  local terminal = workspace.SectionBottomLeft.Terminal
  local infoKiosk = workspace.SectionBottomLeft.InfoKiosk

  animate.terminalScreen(terminal)
  animate.terminalButtons(terminal)
  animate.infoKiosk(infoKiosk)
end

local function initialize()
  runContinuousAnimations()
end

initialize()
