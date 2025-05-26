local Class = require("laravel.utils.class")

---@class laravel.loaders.routes_cache_loader
---@field cache laravel.services.cache
---@field rotues_loader laravel.loaders.routes_loader
---@field key string key to store the routes
---@field timeout number seconds for the cache
local RoutesCacheLoader = Class({
  cache = "laravel.services.cache",
  rotues_loader = "laravel.loaders.routes_loader",
}, { key = "laravel-routes", timeout = 60 })

---@return laravel.dto.artisan_routes[]
function RoutesCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.rotues_loader:load()
  end)
end

return RoutesCacheLoader

