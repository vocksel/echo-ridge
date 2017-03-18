--[[
  Expect
  ======

  Provides type checking and consistent error messages when using assert().

  Usage
  -----

  Simply asserting that an object in the game is a BasePart:

    local function onlyAcceptParts(object)
      assert(expect(object, "BasePart", 1, "onlyAcceptParts"))
      -- bad argument #1 to 'onlyAcceptParts' (BasePart expected, got nil)"
    end

  Checking a value against multiple types:

    local function tell(nameOrId, msg)
      assert(expect(nameOrId, { "string", "number" }, 1, "tell"))
      -- bad argument #1 to 'tell' (string/number expected, got nil)

      assert(expect(msg, "string", 2, "tell"))
      -- bad argument #2 to 'tell' (string expected, got nil)
    end

  Parameters
  ----------

  value (any)
    This is the value whose type will be compared against the list of types
    specified in the next parameter.

  types (string/table)
    A string of one of the Lua or Roblox types. Can also be a table containing
    multiple strings for all the types you want to allow.

  argNumber (int)
    The position of the argument you're checking.

    For example, if you had the following function, the `name` argument is at
    position 1, and the `msg` argument is at position 2.

      local function tell(nameOrId, msg)
        -- ...
      end

    This is used to output which argument was the cause of the error.

  funcName (string)
    The name of the function where the assertion failed.
--]]

local function formatClassNames(classNames)
  return table.concat(classNames, "/")
end

local function getClassName(value)
  local type = typeof(value)
  if type == "Instance" then
    return value.ClassName
  else
    return type
  end
end

local function getMessage(value, classNames, argNumber, funcName)
  return string.format("bad argument #%i to '%s' (%s expected, got %s)",
    argNumber, funcName, formatClassNames(classNames), getClassName(value))
end

local function expect(value, classNames, argNumber, funcName)
  -- Allows the user to pass in a table or string for the expected classes.
  if type(classNames) == "string" then
    classNames = { classNames }
  end

  for _, className in ipairs(classNames) do
    local isRobloxClass = typeof(value) == "Instance" and value:IsA(className)
    local isLuaClass = typeof(value) == className

    if not isRobloxClass and not isLuaClass then
      -- Because this function is used with assert(), we return the arguments it
      -- expects. `false` is the condition, causing the assertion to fail and
      -- display the message.
      return false, getMessage(value, classNames, argNumber, funcName)
    end
  end

  return true
end

return expect
