local Class = require("laravel.utils.class")

---@class laravel.loaders.views_cache_loader
---@field cache laravel.services.cache
---@field views_loader laravel.loaders.views_loader
---@field key string key to store the views
---@field timeout number seconds for the cache
local ViewsCacheLoader = Class({
  cache = "laravel.services.cache",
  views_loader = "laravel.loaders.views_loader",
}, { key = "laravel-views", timeout = 60 })

---@return laravel.dto.artisan_views[], string?
function ViewsCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.views_loader:load()
  end)
end

return ViewsCacheLoader
