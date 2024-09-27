---@class LaravelCacheViewsPprovider : LaravelProvider
local views_cache_provider = {}

function views_cache_provider:register(app)
  app:singeltonIf("cache_views", function()
    return require("laravel.services.cache_decorator"):new(app("views"))
  end)

  app:associate('completion', {
    views = 'cache_views'
  })
end

function views_cache_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.views_cache", {})

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "*.blade.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_views"):forget()
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      if
        ev.data.cmd == "artisan"
        and (
          ev.data.args[1] == "make:view"
          or
          ev.data.args[1] == "livewire:make"
          or
          ev.data.args[1] == "make:livewire"
        )
      then
        app("cache_views"):forget()
      end
    end,
  })
end

return views_cache_provider
