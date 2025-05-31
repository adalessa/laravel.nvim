local app = require("laravel.core.app")
local events = require("laravel.events")

local flush_cache = {
  signature = "cache:flush",
  description = "Flush the plugin cache",
}

function flush_cache:handle()
  ---@type laravel.services.cache
  local cache = app:make("laravel.services.cache")
  cache:flush()
  vim.api.nvim_exec_autocmds("User", {
    pattern = events.CACHE_FLUSHED,
  })
end

return flush_cache
