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

function artisan:version(callback)
  self.api:async("artisan", { "--version" }, function(response)
    if response:successful() then
      callback(response:first():match("Laravel Framework ([%d%.]+)"))
    else
      callback(nil)
    end
  end)
end

function artisan:available(callback)
  callback(self.env:get_executable("artisan") ~= nil)
end

return artisan
