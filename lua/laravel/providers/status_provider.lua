---@class LaravelStatusprovider: laravel.providers.provider
local status_provider = {}

---@param app laravel.app
function status_provider:register(app)
  app:singeltonIf("laravel.services.status")
  app:alias("status", "laravel.services.status")
end

---@param app laravel.app
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
