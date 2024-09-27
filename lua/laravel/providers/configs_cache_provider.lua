---@class LaravelCacheConfigPprovider : LaravelProvider
local configs_cache_provider = {}

function configs_cache_provider:register(app)
  app:singeltonIf("cache_configs", "laravel.services.configs_cache_decorator")

  app:associate('completion', {
    configs = 'cache_configs'
  })
end

function configs_cache_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.configs_cache", {})

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "configs/*.php",
    callback = function()
      if not app("env"):is_active() then
        return
      end
      app("cache_configs"):forget()
    end,
  })
end

return configs_cache_provider
