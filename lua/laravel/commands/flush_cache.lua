local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "cache:flush",
  description = "Flush the plugin cache",
  handle = nio.create(function()
    ---@type laravel.services.cache
    local cache = app:make("laravel.services.cache")
    cache:flush()
  end, 1),
}
