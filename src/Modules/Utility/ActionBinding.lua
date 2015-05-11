--[[
  Simple library for using ROBLOX's ContextActionService.

  This is purely a wrapper for the  BindAction and UnbindAction methods.
  The project requires a loop to be run, which will constantly attempt to
  bind actions.

  Conditions to make sure that an action is registered are put in place so that
  actions don't get constantly re-registered inside of the loop.
--]]

local actionBinding = {}

local contextAction = game:GetService("ContextActionService")

local function isActionRegistered(actionName)
  local actionInfo = contextAction:GetBoundActionInfo(actionName)
  return actionInfo.inputTypes and true or false
end

function actionBinding.bindAction(actionName, ...)
  if not isActionRegistered(actionName) then
    contextAction:BindAction(actionName, ...)
  end
end

function actionBinding.unbindAction(actionName)
  if isActionRegistered(actionName) then
    contextAction:UnbindAction(actionName)
  end
end

return actionBinding
