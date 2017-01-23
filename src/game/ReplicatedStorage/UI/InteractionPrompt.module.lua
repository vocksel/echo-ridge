--[[
  InteractionPrompt
  =================

  This is used in conjunction with area-detection to contextually present the
  player with a prompt to interact while they're within range of the area.

  Constructors
  ------------

  InteractionPrompt.new(Instance parent, Enum input)
    `parent` is where you want to parent the InteractionPrompt to. Typically
    this would be the PlayerGui of a LocalPlayer, but this allows you to
    organize the InteractionPrompt into folders too.

    `input` is any one of ContextActionService.BindAction's accepted user input
    types. This could be a KeyCode, a mouse button, etc.

  Properties
  ----------

  self.Prompt
    Reference to the TextLabel that we show on screen to prompt the user to
    interact.

    Intended for internal use only.

  self.DefaultPosition
    This is self.Prompt's default position so that we can return to it later
    after hiding self.Prompt.

    Intended for internal use only.

  Methods
  -------

  self:Show()
    Tweens the prompt on-screen.

  self:QuickShow()
    Instantly moves the prompt on screen.

    This should be used if you need immediate feedback and you don't want to
    wait for the tweening to happen.

  self:Hide()
    Tweens the prompt off-screen.

  self:QuickHide()
    Instantly moves the prompt off-screen.

    This should be used if you need immediate feedback and you don't want to
    wait for the tweening to happen.

  Usage
  -----

  local players = game:GetService("Players")
  local contextAction = game:GetService("ContextActionService")

  local InteractionPrompt = require(Path.To.InteractionPrompt)

  local player = players.LocalPlayer
  local playerGui = player.PlayerGui

  local input = Enum.KeyCode.E

  -- input.Name returns "E". This allows us to use the Enum for binding and the
  -- key name for the UI.
  local prompt = InteractionPrompt.new(playerGui, input.Name)

  local function bind()
    local function action(_, inputState)
      if inputState == Enum.UserInputState.End then	return end
      print("Interacted")
    end

    prompt:Show()
    contextAction:BindAction("Interact", action, true, input)
  end

  local function unbind()
    prompt:Hide()
    contextAction:UnbindAction("Interact")
  end

  -- In a real scenario, you would use some form of area detection so you know
  -- when a player is within range of what you want them to interact with,
  -- that way you're not showing the interaction prompt constantly.
  --
  -- In this example, we're just going to use a simple while loop to flip
  -- between bound and unbound. Area detection is outside the scope of this
  -- usage example.
  while wait(2) do
    bind()
    wait(2)
    unbind()
  end

  History
  -------

  In a past interation we had controller support implemented, where we would
  switch from a keyboard key to a controller button depending on the last input
  that was used.

  Ultimately this was scrapped because of how much code was required to pull it
  off. Putting an image inbetween text requires a lot of alignment code and for
  the time being we just need a basic keyboard implementation.
--]]

-- This is the message that will appear on-screen when the InteractionPrompt's
-- gui is shown. %s is `inputName` gets passed in when instantiating.
local INTERACT_MESSAGE = "Press [%s] to interact"

-- Used for moving the prompt off the screen when we don't want it visible.
local function getOffScreenPosition(gui)
  local pos = gui.Position
  return UDim2.new(pos.X.Scale, pos.X.Offset, 1, 0)
end

-- This is used for the QuickShow/QuickHide methods. There was an issue where
-- trying to simply set Position was causing the Gui to stay on-screen if the
-- Gui was still tweening.
--
-- Now we're using TweenPosition with a 0 second delay so it will tween
-- instantly, and setting the override so any current tweening can't stop it.
local function instantTween(gui, pos)
  gui:TweenPosition(pos, nil, nil, 0, true)
end


--------------------------------------------------------------------------------
-- UI Creation
--------------------------------------------------------------------------------

local function createScreenGui(parent)
  local screen = Instance.new("ScreenGui", parent)
  screen.Name = "InteractionPrompt"

  return screen
end

local function createLabel(parent, text)
  local label = Instance.new("TextLabel", parent)
  label.Text = text
  label.Transparency = 1
  label.TextTransparency = 0
  label.Font = Enum.Font.SourceSansBold
  label.FontSize = Enum.FontSize.Size24
  label.TextColor3 = Color3.fromRGB(255, 201, 37)
  label.TextStrokeColor3 = Color3.fromRGB(34, 14, 23)
  label.TextStrokeTransparency = .5

  label.Size = UDim2.new(1, 0, 0, 42)
  label.Position = UDim2.new(0, 0, 1, -150)

  return label
end

local function createUI(parent, inputName)
  local interactMsg = ("Press [%s] to interact"):format(inputName)

  local screen = createScreenGui(parent)
  local prompt = createLabel(screen, interactMsg)

  return prompt
end


--------------------------------------------------------------------------------
-- InteractionPrompt
--------------------------------------------------------------------------------

local InteractionPrompt = {}
InteractionPrompt.__index = InteractionPrompt

function InteractionPrompt.new(playerGui, input)
  local self = {}
  setmetatable(self, InteractionPrompt)

  local prompt = createUI(playerGui, input)

  self.Prompt = prompt
  self.DefaultPosition = prompt.Position

  self:QuickHide()

  return self
end

function InteractionPrompt:Show()
  self.Prompt:TweenPosition(self.DefaultPosition, nil, "Quint", .5, true)
end

function InteractionPrompt:QuickShow()
  instantTween(self.Prompt, self.DefaultPosition)
end

function InteractionPrompt:Hide()
  local pos = getOffScreenPosition(self.Prompt)
  self.Prompt:TweenPosition(pos, "In", "Back", .75, true)
end

function InteractionPrompt:QuickHide()
  local pos = getOffScreenPosition(self.Prompt)
  instantTween(self.Prompt, pos)
end

return InteractionPrompt
