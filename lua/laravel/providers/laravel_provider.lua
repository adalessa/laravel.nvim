---@class laravel.providers.provider
---@field name string
---@field register fun(app: laravel.core.app): nil
---@field boot fun(app: laravel.core.app): nil

---@class laravel.providers.laravel_provider: laravel.providers.provider
local laravel_provider = { name = "laravel.providers.laravel_provider" }

---@param app laravel.core.app
function laravel_provider:register(app)
  app:singletonIf("laravel.services.cache")

  app:singletonIf("laravel.core.env")

  app:singletonIf("laravel.services.path")

  app:singletonIf("laravel.core.config", function()
    return require("laravel.core.config"):new(vim.fn.stdpath("data") .. "/laravel/config.json")
  end)

  app:singletonIf("laravel.utils.log", function()
    return require("laravel.utils.log"):new(
      vim.fn.stdpath("data") .. "/laravel/logs",
      app("laravel.services.config")("debug_level")
    )
  end)
end

---@param app laravel.core.app
function laravel_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel_provider", {})

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = { "web.php", "api.php" },
    callback = function()
      app("laravel.services.cache"):forget("laravel-routes")
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = { "*.blade.php" },
    callback = function()
      app("laravel.services.cache"):forget("laravel-views")
    end,
  })

  -- Add the runner to the global
  Laravel.run = function(...)
    return app("runner"):run(...)
  end
end

return laravel_provider
