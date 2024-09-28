local promise = require("promise")

---@class LaravelArtisanService
---@field api LaravelApi
---@field env LaravelEnvironment
local artisan = {}

function artisan:new(api, env)
  local instance = {
    api = api,
    env = env,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function artisan:version()
  return self.api:send("artisan", { "--version" }):thenCall(
  ---@param response ApiResponse
    function(response)
      return response:first():match("Laravel Framework ([%d%.]+)")
    end,
    function()
      return promise.resolve(nil)
    end
  )
end

---@return Promise
function artisan:available()
  return promise.resolve(self.env:get_executable("artisan") ~= nil)
end

return artisan
