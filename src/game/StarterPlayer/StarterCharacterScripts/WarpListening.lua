-- ClassName: LocalScript

--[[
  WarpListening
  =============

  Hooks up the Warps in the game to allow the player to travel between areas in
  the overworld and interiors.
--]]

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local remotes = require(replicatedStorage.Events.Remotes)
local Warp = require(replicatedStorage.Warping.Warp)
local Trigger = require(replicatedStorage.Triggers.Trigger)

local character = players.LocalPlayer.Character
local rootPart = character:FindFirstChild("HumanoidRootPart")
local getComponents = remotes.getFunction("GetComponents")

local function setupTriggerWarps()
  local function setupTrigger(warp, triggerPart)
    local trigger = Trigger.new(triggerPart)

    trigger.Touched:connect(function(otherPart)
      if otherPart == rootPart then
        warp:TeleportToPad(character)
      end
    end)
  end

  local function setupWarp(warpModel)
    local linkedWarp = warpModel.LinkedWarp.Value
    local triggerPart = warpModel.Trigger
    local warp = Warp.new(linkedWarp.Pad)

    setupTrigger(warp, triggerPart)
  end

  local triggerWarps = getComponents:InvokeServer("TriggerWarp")

  for _, warpModel in ipairs(triggerWarps) do
    setupWarp(warpModel)
  end
end

setupTriggerWarps()
