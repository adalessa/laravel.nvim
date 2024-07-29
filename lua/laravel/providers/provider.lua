-- a provider should have a register and a boot method
local provider = {}

---@param app function
function provider:register(app)
  app():register_many({
    api = "laravel.api",
    env = "laravel.environment",
    class = "laravel.services.class",
  })

  -- SERVICES
  app():register_many({
    artisan = "laravel.services.artisan",
    commands = "laravel.services.commands",
    composer = "laravel.services.composer",
    configs = "laravel.services.configs",
    history = "laravel.services.history",
    paths = "laravel.services.paths",
    php = "laravel.services.php",
    routes = "laravel.services.routes",
    views = "laravel.services.views",
    runner = "laravel.services.runner",
    ui_handler = "laravel.services.ui_handler",
  })

  -- CACHE DECORATORS
  app():register_many({
    cache_commands = function()
      return require("laravel.services.cache_decorator"):new(app("commands"))
    end,
    cache_routes = function()
      return require("laravel.services.cache_decorator"):new(app("routes"))
    end,
  })
end

---@param app function
function provider:boot(app)
  app("env"):boot()

  require("laravel.treesitter_queries")

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      require("laravel.app")("env"):boot()
    end,
  })
end

return provider
