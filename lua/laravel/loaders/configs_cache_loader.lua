local Class = require("laravel.utils.class")

---@class laravel.loaders.configs_cache_loader: laravel.loaders.configs_loader
---@field cache laravel.services.cache
---@field configs_loader laravel.loaders.configs_loader
---@field key string key to store the configs
---@field timeout number seconds for the cache
local ConfigsCacheLoader = Class({
  cache = "laravel.services.cache",
  configs_loader = "laravel.loaders.configs_loader",
}, {key = "laravel-configs", timeout = 60})

---@return string[], laravel.error
function ConfigsCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.configs_loader:load()
  end)
end

return ConfigsCacheLoader
