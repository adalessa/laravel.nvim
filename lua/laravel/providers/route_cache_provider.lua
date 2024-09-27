---@class LaravelCacheRoutePprovider : LaravelProvider
local route_cache_provider = {}

function route_cache_provider:register(app)
  app:singeltonIf("cache_routes", function()
    return require("laravel.services.cache_decorator"):new(app("routes"))
  end)

  app:associate('completion', {
    routes = 'cache_routes'
  })

  app:associate('routes_picker', {
    routes = 'cache_routes'
  })
end

function route_cache_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.route_cache", {})

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "routes/*.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_routes"):forget()
    end,
  })
end

return route_cache_provider
