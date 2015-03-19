--[[
  Contains functions to run animations on in-game objects.

  Each function should be run inside of a coroutine, as the tweening library
  will block all operations until the tween is complete.
--]]

local animate = {}

local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local tween = nevermore.LoadLibrary("Tween")

local DEFAULT_EASING = tween.Ease.InOut.Quad

local function newThreadedLoop(func)
  return coroutine.wrap(function()
    while wait() do
      func()
    end
  end)()
end

function animate.terminalScreen(terminal)
  local display = terminal.Display
  local baseReflectance = display.Reflectance
  local newReflectance = baseReflectance + .5
  local animSpeed = 1.5

  local function animateScreen()
    tween:TweenNumber(display, "Reflectance", baseReflectance, animSpeed, DEFAULT_EASING)
    wait(.25)
    tween:TweenNumber(display, "Reflectance", newReflectance, animSpeed, DEFAULT_EASING)
  end

  newThreadedLoop(animateScreen)
end

function animate.terminalButtons(terminal)
  local buttonList = terminal.GlowyButtons:GetChildren()
  local animSpeed = .25

  local recentlyAnimated do
    local lastAnimated

    function recentlyAnimated(button)
      if button == lastAnimated then
        return true
      else
        lastAnimated = button
        return false
      end
    end
  end

  local function animateButton(button)
    button.Reflectance = .5
    tween:TweenNumber(button, "Reflectance", 0, animSpeed, DEFAULT_EASING)
  end

  local function animateButtons()
    local button = buttonList[math.random(#buttonList)]
    if not recentlyAnimated(button) then
      animateButton(button)
    end
    wait()
  end

  newThreadedLoop(animateButtons)
end

function animate.infoKiosk(infoKiosk)
  local display = infoKiosk.Display
  local outer = display.Outer

  local function animateDisplay()
    outer.Reflectance = .9
    tween:TweenNumber(outer, "Reflectance", 0, 1, DEFAULT_EASING)
  end

  newThreadedLoop(animateDisplay)
end

return animate
