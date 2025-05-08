---@class laravel.providers.provider
local laravel_provider = {}

---@param app laravel.app
function laravel_provider:register(app)
  app:alias("api", "laravel.api")
  app:alias("tinker", "laravel.tinker")
  app:alias("pickers", "laravel.pickers_manager")
  app:alias("options", "laravel.services.options")

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

  app:singeltonIf("laravel.services.cache")
  app:alias("cache", "laravel.services.cache")

  app:singeltonIf("laravel.env")
  app:alias("env", "laravel.env")

  app:singeltonIf("laravel.config", function()
    return require("laravel.config"):new(
      vim.fn.stdpath("data") .. "/laravel/config.json"
    )
  end)
  app:command("configure", function()
    app("laravel.env"):configure()
  end)
end

---@param app laravel.app
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
