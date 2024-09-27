---@class LaravelProvider
local provider = {}

---@param app LaravelApp
function provider:register(app)
  app:bindIf("api", "laravel.api")
  app:bindIf("templates", "laravel.templates")
  app:singeltonIf("env", "laravel.services.environment")
  app:bindIf("class", "laravel.services.class")
  app:singeltonIf("cache", "laravel.services.cache")

  -- SERVICES
  app:bindIf("artisan", "laravel.services.artisan")
  app:bindIf("commands", "laravel.services.commands")
  app:bindIf("composer", "laravel.services.composer")
  app:bindIf("configs", "laravel.services.configs")
  app:bindIf("paths", "laravel.services.paths")
  app:bindIf("php", "laravel.services.php")
  app:bindIf("routes", "laravel.services.routes")
  app:bindIf("runner", "laravel.services.runner")
  app:bindIf("ui_handler", "laravel.services.ui_handler")
  app:bindIf("view_finder", "laravel.services.view_finder")
end

---@param app LaravelApp
function provider:boot(app)
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

return provider
