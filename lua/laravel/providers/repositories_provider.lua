---@class LaravelRepositoriesProvider : LaravelProvider
local repositories_provider = {}

function repositories_provider:register(app)
  app:bindIf('commands_repository', 'laravel.repositories.commands_repository')
  app:bindIf('cache_commands_repository', 'laravel.repositories.cache_commands_repository')

  app:bindIf('routes_repository', 'laravel.repositories.routes_repository')
  app:bindIf('cache_routes_repository', 'laravel.repositories.cache_routes_repository')

  app:bindIf('resources_repository', 'laravel.repositories.resources_repository')
  app:bindIf('cache_resources_repository', 'laravel.repositories.cache_resources_repository')

  app:bindIf('views_repository', 'laravel.repositories.views_repository')
  app:bindIf('cache_views_repository', 'laravel.repositories.cache_views_repository')

  app:bindIf('configs_repository', 'laravel.repositories.configs_repository')
  app:bindIf('cache_configs_repository', 'laravel.repositories.cache_configs_repository')

  app:bindIf('composer_repository', 'laravel.repositories.composer_repository')
end

function repositories_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.repositories", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      if ev.data.cmd == "composer" then
        app("cache_commands_repository"):clear()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "app/Console/Commands/*.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_routes_repository"):clear()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "routes/*.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_routes_repository"):clear()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "*.blade.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_views_repository"):clear()
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
      app("cache_views_repository"):clear()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "configs/*.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_configs_repository"):clear()
    end,
  })
end

return repositories_provider
