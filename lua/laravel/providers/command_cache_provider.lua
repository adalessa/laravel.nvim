---@class LaravelCacheCommandProvider : LaravelProvider
local command_cache_provider = {}

function command_cache_provider:register(app)
  app:singeltonIf("cache_commands", function()
    return require("laravel.services.cache_decorator"):new(app("commands"))
  end)

  app:associate('artisan_picker', {
    commands = 'cache_commands'
  })
end

function command_cache_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.command_cache", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      if ev.data.cmd == "composer" then
        app("cache_commands"):forget()
      end
    end,
  })
end

return command_cache_provider
