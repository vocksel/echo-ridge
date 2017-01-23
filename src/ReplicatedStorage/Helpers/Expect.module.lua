--[[
  Expect
  ======

  Contains functions for use with assert() calls.

  These are used to take the class checking out of assertion calls so you don't
  need to write tons of conditions.

  Usage
  -----

  local function onlyAcceptParts(obj)
    assert(expect.class(obj, "BasePart"), string.format("bad argument #1 to "..
      "onlyAcceptParts (BasePart expected, got %s)", expect.getType(obj)))

    doSomethingWithThePart(obj)
  end

  API
  ---

  expect.getType(Instance obj)
    Returns the class name of `obj`.

    This is used with the assertion message to output the type of the object
    you're working with.

    This function accounts for both ROBLOX and Lua classes, so you don't need to
    worry about any special type checking.

  expect.class(Instance obj, string className)
    Checks if `obj` is a `className` instance.

    This first checks if obj is one of ROBLOX's classes, and if that fails
    checks if it's one of the built-in Lua classes.

  expect.classes(Instance obj, string ...)
    Allows you to check if `obj` is any number of classes.

  expect.basePart(Instance obj)
    A quick function to easily check if `obj` is a BasePart.
--]]

local function isRobloxInstance(obj)
  return type(obj) == "userdata" and obj.ClassName
end

local expect = {}

function expect.getType(obj)
  return isRobloxInstance(obj) or type(obj)
end

function expect.class(obj, className)
  local isRobloxClass = isRobloxInstance(obj) and obj:IsA(className)
  local isLuaClass = type(obj) == className
  return  isRobloxClass or isLuaClass
end

function expect.classes(obj, ...)
  for _, className in ipairs{...} do
    if expect.class(obj, className) then
      return true
    end
  end
  return false
end

function expect.basePart(obj)
  return expect.class(obj, "BasePart")
end

return expect
