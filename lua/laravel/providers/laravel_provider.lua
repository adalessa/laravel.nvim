---@class laravel.providers.provider
---@field register fun(app: laravel.core.app): nil
---@field boot fun(app: laravel.core.app): nil

---@class laravel.providers.laravel_provider: laravel.providers.provider
local laravel_provider = { name = "laravel.providers.laravel_provider" }

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

  app:singletonIf("history", "laravel.services.history")
  app:command("history", function()
    app("pickers"):run("history")
  end)

  app:singletonIf("laravel.services.cache")
  app:alias("cache", "laravel.services.cache")

  app:singletonIf("laravel.core.env")
  app:alias("env", "laravel.core.env")

  app:singletonIf("laravel.core.config", function()
    return require("laravel.core.config"):new(vim.fn.stdpath("data") .. "/laravel/config.json")
  end)
  app:command("configure", function()
    app("laravel.core.env"):configure()
  end)
end

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

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = { "LaravelCommandRun" },
    callback = function(ev)
      app("history"):add(ev.data.job_id, ev.data.cmd, ev.data.args, ev.data.options)
    end,
  })
end

return laravel_provider
