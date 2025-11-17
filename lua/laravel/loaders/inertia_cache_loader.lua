local Class = require("laravel.utils.class")

---@class laravel.loaders.inertia_cache_loader
---@field cache laravel.services.cache
---@field inertia_loader laravel.loaders.inertia_loader
---@field key string key to store the views
---@field timeout number seconds for the cache
local InertiaCacheLoader = Class({
  cache = "laravel.services.cache",
  inertia_loader = "laravel.loaders.inertia_loader",
}, { key = "laravel-inertia", timeout = 300 })

---@return laravel.dto.inertia, laravel.error
function InertiaCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.inertia_loader:load()
  end)
end

return InertiaCacheLoader
