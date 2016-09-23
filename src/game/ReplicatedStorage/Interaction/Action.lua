--[[
  Action
  ======

  Quick and easy interface to ContextActionService.

  This is just a wrapped around CAS that comes with the added benefit of being
  able to bind and unbind an action without needing to retype the action's name.

  Constructors
  ============

  Action.new(string name, table inputs)
    `name` is the action's name (first argument to CAS:BindAction()), and
    `inputs` is a list of any of the input types CAS accepts.

    You can either pass in a single input or an array of inputs.

  Properties
  ==========

  Name
    The name you set when instatiating. You can change this at any time, though
    if you already bound the action it won't update until you rebind it.

  UseMobileButton=false
    This lets you choose whether or not to create a button on mobile devices so
    they can use the action.

  Inputs
    List of all the input types you passed in.

  Methods
  =======

  SetBoundFunction(function f)
    Sets `f` as the function you want to use when you bind the action.

    You can only bind one function per Action.

  Bind()
    Binds an action using the data given (name, inputs, UseMobileButton, and the
    bound function). You must set a bound function before you run this.

  Unbind()
    Unbinds the action. Plain and simple.

  Usage
  =====

  local action = Action.new("Interact", { Enum.KeyCode.E })

  action:SetBoundFunction(function(inputState)
    if inputState == Enum.InputState.End then return end
    print("Hello, World!")
  end)

  -- Now whenever you press E, "Hello, World" will be output to the console.
  action:Bind()
--]]

local contextAction = game:GetService("ContextActionService")

local Action = {}
Action.__index = Action

function Action.new(name, inputs)
  local self = {}
  setmetatable(self, Action)

  self.Name = name
  self.UseMobileButton = false
  self.BoundFunction = nil

  return self
end

function Action:SetBoundFunction(f)
  self.BoundFunction = f
end

function Action:Bind()
  assert(self.BoundFunction, "You need to use SetBoundFunction() before you "..
    "can run Bind().")

  contextAction:BindAction(self.Name, self.BoundFunction, self.UseMobileButton,
    unpack(self.Inputs))
end

function Action:Unbind()
  contextAction:UnbindAction(self.Name)
end

return Action
