-- ClassName: LocalScript

local players = game:GetService("Players")
local run = game:GetService("RunService")

local function getTopDownOffset(dist)
  return Vector3.new(-dist, dist, dist)
end

local OFFSET = getTopDownOffset(45)
local FIELD_OF_VIEW = 25

local client = players.LocalPlayer
local camera = workspace.CurrentCamera

camera.FieldOfView = FIELD_OF_VIEW

local function lookAt(pos)
  local cameraPos = pos + OFFSET
  camera.CoordinateFrame = CFrame.new(cameraPos, pos)
end

local function onRenderStep()
  local character = client.Character
  local rootPart = character:FindFirstChild("HumanoidRootPart")

  if character and rootPart then
    -- The ROBLOX Wiki describes this as an important property to update, as
    -- "certain visuals will be more detailed and will update more frequently".
    --
    -- What this means is unclear, or if it even has any effect, but we're
    -- including this property just in case it makes a difference.
    --
    -- Source: http://wiki.roblox.com/index.php?title=API:Class/Camera/Focus
    camera.Focus = rootPart.CFrame

    lookAt(rootPart.Position)
  end
end

run:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
