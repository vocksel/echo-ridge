-- ClassName: LocalScript

local OFFSET = Vector3.new(-45, 45, 45)
local FIELD_OF_VIEW = 25

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local run = game:GetService("RunService")

camera.FieldOfView = FIELD_OF_VIEW

local function onRenderStep()
  local playerPosition = player.Character.Torso.Position
  local cameraPosition = playerPosition + OFFSET
  camera.CoordinateFrame = CFrame.new(cameraPosition, playerPosition)
end

run:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
