local app = require("laravel.core.app")
local events = require("laravel.events")
local nio = require("nio")

local flush_cache = {
  signature = "cache:flush",
  description = "Flush the plugin cache",
}

flush_cache.handle = nio.create(function()
  ---@type laravel.services.cache
  local cache = app:make("laravel.services.cache")
  cache:flush()
  vim.schedule(function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = events.CACHE_FLUSHED,
    })
  end)
end, 1)

return flush_cache
