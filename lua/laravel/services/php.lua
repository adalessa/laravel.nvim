local promise = require("promise")

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

---@return Promise
function php:version()
  return self.api:send("php", { "-v" }):thenCall(
  ---@param response ApiResponse
    function(response)
      return response:first():match("PHP ([%d%.]+)")
    end,
    function()
      return promise.resolve(nil)
    end
  )
end

---@return Promise
function php:available()
  return promise.resolve(self.env:get_executable("php") ~= nil)
end

return php
