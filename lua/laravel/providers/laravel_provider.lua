---@class laravel.providers.provider
---@field register fun(app: laravel.core.app): nil
---@field boot fun(app: laravel.core.app): nil

---@class laravel.providers.laravel_provider: laravel.providers.provider
local laravel_provider = { name = "laravel.providers.laravel_provider" }

function laravel_provider:register(app)
  app:alias("api", "laravel.services.api")
  app:alias("tinker", "laravel.services.tinker")
  app:alias("pickers", "laravel.pickers.pickers_manager")

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

  -- Set Property in Global
  Laravel.pickers = setmetatable({
    list = function()
      return vim.tbl_keys(app:make("pickers"):get_pickers())
    end,
  }, {
    __index = function(_, key)
      local pickers = app:make("pickers")
      if not pickers:exists(key) then
        error("Picker not found: " .. key .. " in provider " .. pickers.name)
      end

      return setmetatable({}, {
        __call = function(_, ...)
          return pickers:run(key, ...)
        end,
      })
    end,
  })
end

return laravel_provider
