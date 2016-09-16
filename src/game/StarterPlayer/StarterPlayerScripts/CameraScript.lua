-- ClassName: LocalScript

local OFFSET = Vector3.new(-45, 45, 45)
local FIELD_OF_VIEW = 25

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local run = game:GetService("RunService")

camera.FieldOfView = FIELD_OF_VIEW

local function lookAt(pos)
  local cameraPos = pos + OFFSET
  camera.CoordinateFrame = CFrame.new(cameraPos, pos)
end

local function onRenderStep()
  local character = player.Character
  local rootPart = character:FindFirstChild("HumanoidRootPart")

  if character and rootPart then
    lookAt(rootPart.Position)
  end
end

run:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
