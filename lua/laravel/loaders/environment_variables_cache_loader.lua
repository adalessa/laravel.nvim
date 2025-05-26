local Class = require("laravel.utils.class")

---@class laravel.loaders.environment_variables_cache_loader: laravel.loaders.environment_variables_loader
---@field cache laravel.services.cache
---@field environment_variables_loader laravel.loaders.environment_variables_loader
---@field key string key to store the environment variables
---@field timeout number seconds for the cache
local EnvironmentVariablesCacheLoader = Class({
  cache = "laravel.services.cache",
  environment_variables_loader = "laravel.loaders.environment_variables_loader",
}, { key = "laravel-environment-variables", timeout = 60 })

function EnvironmentVariablesCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.environment_variables_loader:load()
  end)
end

return EnvironmentVariablesCacheLoader
