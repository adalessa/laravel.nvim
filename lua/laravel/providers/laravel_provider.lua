---@class laravel.providers.provider
---@field name string
---@field register fun(app: laravel.core.app): nil
---@field boot fun(app: laravel.core.app): nil

---@class laravel.providers.laravel_provider: laravel.providers.provider
local laravel_provider = { name = "laravel.providers.laravel_provider" }

---@param app laravel.core.app
function laravel_provider:register(app)
  app:alias("api", "laravel.services.api")
  app:alias("tinker", "laravel.services.tinker")

  -- SERVICES
  app:alias("class", "laravel.services.class")
  app:alias("env_vars", "laravel.services.env")
  app:alias("model", "laravel.services.model")
  app:alias("related", "laravel.services.related")
  app:alias("composer", "laravel.services.composer")
  app:alias("runner", "laravel.services.runner")
  app:alias("view_finder", "laravel.services.view_finder")
  app:alias("views", "laravel.services.views")
  app:alias("gf", "laravel.services.gf")

  app:singletonIf("laravel.services.cache")
  app:alias("cache", "laravel.services.cache")

  app:singletonIf("laravel.core.env")
  app:alias("env", "laravel.core.env")

  app:singletonIf("laravel.core.config", function()
    return require("laravel.core.config"):new(vim.fn.stdpath("data") .. "/laravel/config.json")
  end)
  app:addCommand("laravel.commands.configure", function()
    return {
      signature = "env:configure",
      description = "Configure Laravel.nvim environment",
      handle = function()
        app("laravel.core.env"):configure()
      end,
    }
  end)
  app:addCommand("laravel.commands.configure.open", function()
    return {
      signature = "env:configure:open",
      description = "Open Laravel.nvim configuration for environments",
      handle = function()
        vim.cmd("edit " .. app("laravel.core.config").path)
      end,
    }
  end)

  app:singletonIf("laravel.utils.log", function()
    return require("laravel.utils.log"):new(
      vim.fn.stdpath("data") .. "/laravel/logs",
      app("laravel.services.config")("debug_level")
    )
  end)
  app:alias("log", "laravel.utils.log")
  app:addCommand("laravel.commands.logs.open", function()
    return {
      signature = "logs:open",
      description = "Open Laravel.nvim logs",
      handle = function()
        vim.cmd("edit " .. app("laravel.utils.log").path)
      end,
    }
  end)
end

---@param app laravel.core.app
function laravel_provider:boot(app)
  app:make("env"):boot()

  require("laravel.utils.treesitter_queries")

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      app:make("env"):boot()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = { "web.php", "api.php" },
    callback = function()
      app("laravel.services.cache"):forget("laravel-routes")
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = { "LaravelCommandRun" },
    callback = function(ev)
      if ev.data.cmd == "composer" then
        app("laravel.services.cache"):forget("laravel-composer-commands")
      end
    end,
  })

  -- Add the runner to the global
  Laravel.run = function(...)
    return app("runner"):run(...)
  end
end

return laravel_provider
