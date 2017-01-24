-- Simply disabled some of the CoreGui elements that we don't need in the game.

local starterGui = game:GetService("StarterGui")

starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
