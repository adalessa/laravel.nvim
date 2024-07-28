---@class LaravelPhpService
---@field api LaravelApi
---@field env LaravelEnvironment
local php = {}

function php:new(api, env)
  local instance = {
    api = api,
    env = env,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function php:version(callback)
  self.api:async("php", { "-v" }, function(response)
    if response:successful() then
      callback(response:first():match("PHP ([%d%.]+)"))
    else
      callback(nil)
    end
  end)
end

function php:available(callback)
  callback(self.env:get_executable("php") ~= nil)
end

return php
