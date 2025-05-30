local Class = require("laravel.utils.class")
local nio = require("nio")

--[[
invoke class are design to be use as actions.
these actions set up the async environment
Should not return since is not expected
]]--

return function(...)
  local class = Class(...)
  local meta = getmetatable(class)
  meta.__call = function(_, ...)
    if not class.invoke then
      error("Class does not have an 'invoke' method")
    end
    local args = ...
    return nio.run(function()
      return class:invoke(args)
    end)
  end
end
