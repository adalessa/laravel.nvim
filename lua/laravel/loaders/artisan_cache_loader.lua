local Class = require("laravel.utils.class")

---@class laravel.loaders.artisan_cache_loader
---@field cache laravel.services.cache
---@field artisan_loader laravel.loaders.artisan_loader
---@field key string key to store the commands
---@field timeout number seconds for the cache
local ArtisanCacheLoader = Class({
  cache = "laravel.services.cache",
  artisan_loader = "laravel.loaders.artisan_loader",
}, { key = "laravel-commands", timeout = 60 })

---@return laravel.dto.artisan_command[], laravel.error
function ArtisanCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.artisan_loader:load()
  end)
end

return ArtisanCacheLoader
