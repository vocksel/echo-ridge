local InteractionGui = {}
InteractionGui.__index = InteractionGui

local function constructGui(parent, msg, position)
  local gui = Instance.new("ScreenGui", parent)
  gui.Name = "InteractionGui"

  local frame = Instance.new("Frame", gui)
  frame.BackgroundTransparency = 1
  frame.Size = UDim2.new(0,200, 0,50)
  frame.Position = position

  local label = Instance.new("TextLabel", frame)
  label.Text = msg
  label.Size = UDim2.new(1,0, 1,0)
  label.BackgroundTransparency = 1
  label.Font = Enum.Font.SourceSansBold
  label.FontSize = Enum.FontSize.Size18
  label.TextColor3 = Color3.new(240, 240, 240)
  label.TextStrokeColor3 = Color3.new(0, 0, 0)
  label.TextStrokeTransparency = 0

  return gui
end

function InteractionGui.new(parent, msg)
  local self = {}

  self.OffScreen = UDim2.new(.5,-100, 1,0)
  self.OnScreen  = self.OffScreen - UDim2.new(0,0, .25,0)
  self.Gui = constructGui(parent, msg, self.OffScreen)

  return setmetatable(self, InteractionGui)
end

function InteractionGui:Show()
  local gui = self.Gui.Frame
  if gui.Position == self.OffScreen then
    gui:TweenPosition(self.OnScreen, "Out", "Quart", .5, true)
  end
end

function InteractionGui:Hide()
  local gui = self.Gui.Frame
  if gui.Position == self.OnScreen then
    gui:TweenPosition(self.OffScreen, "In", "Back", .3, true)
  end
end

function InteractionGui:Destroy()
  self.Gui:Destroy()
end

return InteractionGui
