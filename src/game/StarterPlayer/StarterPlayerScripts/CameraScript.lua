-- ClassName: LocalScript

local run = game:GetService("RunService")

local function getTopDownOffset(dist)
  return Vector3.new(-dist, dist, dist)
end

local OFFSET = getTopDownOffset(45)
local FIELD_OF_VIEW = 25

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

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
