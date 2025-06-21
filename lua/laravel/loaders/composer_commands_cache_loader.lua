local Class = require("laravel.utils.class")

---@class laravel.loaders.composer_commands_cache_loader: laravel.loaders.composer_commands_loader
---@field cache laravel.services.cache
---@field commands_loader laravel.loaders.composer_commands_loader
---@field key string key to store the commands
---@field timeout number seconds for the cache
local ComposerCommandsCacheLoader = Class({
  cache = "laravel.services.cache",
  commands_loader = "laravel.loaders.composer_commands_loader",
}, {key = "laravel-composer-commands", timeout = 60})

---@async
---@return laravel.dto.composer_command[], laravel.error
function ComposerCommandsCacheLoader:load()
  return self.cache:remember(self.key, self.timeout, function()
    return self.commands_loader:load()
  end)
end

return ComposerCommandsCacheLoader
