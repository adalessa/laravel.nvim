---@class LaravelOptionsService
---@field opts LaravelOptions
local options = {}

function options:new(opts)
  local instance = {
    opts = opts or {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function options:get()
  return self.opts
end

return options
