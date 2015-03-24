-- Name: Client.Main
-- ClassName: LocalScript

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local animate = nevermore.LoadLibrary("Animate")

local function playAnimations()
  local terminal = workspace.SectionBottomLeft.Terminal
  local infoKiosk = workspace.SectionBottomLeft.InfoKiosk

  animate.terminalScreen(terminal)
  animate.terminalButtons(terminal)
  animate.infoKiosk(infoKiosk)
end

local function initialize()
  nevermore.ClearSplash()
  playAnimations()
end

initialize()
