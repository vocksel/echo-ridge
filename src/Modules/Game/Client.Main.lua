-- Name: Client.Main
-- ClassName: LocalScript

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))

local function initialize()
  nevermore.ClearSplash()
end

initialize()
