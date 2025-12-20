local config = require("laravel.services.config")
local notify = require("laravel.utils.notify")

local function initGlobal(app)
  _G.Laravel = setmetatable({
    app = app,
  }, {
    __call = function(_, ...)
      local a = ...
      if not a then
        return app
      end

      return app:make(...)
    end,
  })
end

local function coreBoot(app)
  app:make("env"):boot()

  local group = vim.api.nvim_create_augroup("laravel.core", {})
  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      app:make("env"):boot()
    end,
  })
end

local function register(item, app, args)
  if item.register then
    local ok, res = pcall(function()
      item.register(app, args)
    end)

    if not ok then
      notify.error(string.format("Register Provider: %s. Error: %s", item.name or "(Name missing)", res))
    end
  end
end

local function boot(item, app, args)
  if item.boot then
    local ok, res = pcall(function()
      item.boot(app, args)
    end)
    if not ok then
      notify.error(string.format("Boot Provider: %s. Error: %s", item.name or "(Name missing)", res))
    end
  end
end

local function registerProviders(app)
  vim.tbl_map(function(provider)
    return register(provider, app)
  end, config.get("providers", {}))
end

local function bootProviders(app)
  vim.tbl_map(function(provider)
    return boot(provider, app)
  end, config.get("providers", {}))
end

local function registerUserProviders(app)
  vim.tbl_map(function(provider)
    return register(provider, app)
  end, config.get("user_providers", {}))
end

local function bootUserProviders(app)
  vim.tbl_map(function(provider)
    return boot(provider, app)
  end, config.get("user_providers", {}))
end

return {
  ---@param app laravel.core.app
  ---@param opts table?
  bootstrap = function(app, opts)
    config.set(vim.tbl_deep_extend("force", require("laravel.options.default"), opts or {}))

    registerProviders(app)
    registerUserProviders(app)

    initGlobal(app)
    coreBoot(app)

    bootProviders(app)
    bootUserProviders(app)
  end,
}
