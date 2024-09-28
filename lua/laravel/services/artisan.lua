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

function artisan:info()
  return self.api:send("artisan", { "about", "--json" }):thenCall(function(response)
    return response:json()
  end)
end

return artisan
