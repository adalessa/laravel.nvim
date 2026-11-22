---@type laravel.providers.provider
local status_provider = { name = "laravel.providers.status_provider" }

function status_provider.register(app)
  app:singletonIf("laravel.services.status")
  app:alias("status", "laravel.services.status")

  app:bind("laravel.listeners.status_update_listener", function()
    return {
      event = require("laravel.events.cache_flushed_event"),
      hanle = function()
        app("status"):update()
      end,
    }
  end, { tags = { "listener" } })
end

function status_provider.boot(app)
  if not app:isActive() then
    return
  end

  app("status"):start()

  local group = vim.api.nvim_create_augroup("laravel.status", {})
  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
    group = group,
    callback = function()
      if require("laravel.core.health").isUnavailable() then
        app("status"):update()
      end
    end,
  })
end

return status_provider
