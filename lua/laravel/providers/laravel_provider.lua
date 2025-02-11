---@class LaravelProvider
local laravel_provider = {}

---@param app LaravelApp
function laravel_provider:register(app)
  app:bindIf("api", "laravel.api")
  app:bindIf("tinker", "laravel.tinker")
  app:bindIf("templates", "laravel.templates")
  app:bindIf("pickers", "laravel.pickers_manager")

  -- SERVICES
  app:bindIf("artisan", "laravel.services.artisan")
  app:bindIf("class", "laravel.services.class")
  app:bindIf("env_vars", "laravel.services.env")
  app:bindIf("model", "laravel.services.model")
  app:bindIf("related", "laravel.services.related")
  app:bindIf("composer", "laravel.services.composer")
  app:bindIf("runner", "laravel.services.runner")
  app:bindIf("ui_handler", "laravel.services.ui_handler")
  app:bindIf("view_finder", "laravel.services.view_finder")
  app:bindIf("views", "laravel.services.views")
  app:bindIf("gf", "laravel.services.gf")

  app:singeltonIf("cache", "laravel.services.cache")
  app:singeltonIf("env", "laravel.services.environment")
end

---@param app LaravelApp
function laravel_provider:boot(app)
  app("env"):boot()

  require("laravel.treesitter_queries")

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      app("env"):boot()
    end,
  })
end

return laravel_provider
