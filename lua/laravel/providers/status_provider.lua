---@class laravel.providers.status_provider: laravel.providers.provider
local status_provider = { name = "laravel.providers.status_provider" }

function status_provider:register(app)
  app:singletonIf("laravel.services.status")
  app:alias("status", "laravel.services.status")
end

---@param app laravel.core.app
function status_provider:boot(app)
  if not app:isActive() then
    return
  end

  app("status"):start()

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = { "LaravelCommandRun" },
    callback = function(ev)
      if ev.data.cmd == "composer" then
        app("status"):update()
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = { "LaravelFlushCache" },
    callback = function()
      app("status"):update()
    end,
  })
end

return status_provider
