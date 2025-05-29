local config = require("laravel.services.config")
local notify = require("laravel.utils.notify")

local M = {}

function M:bootstrap(app, opts)
  config.set(vim.tbl_deep_extend("force", require("laravel.options.default"), opts or {}))

  self:registerProviders(app)
  self:registerUserProviders(app)
  self:registerExtensions(app)

  self:initGlobal(app)

  self:bootProviders(app)
  self:bootUserProviders(app)
  self:bootExtensions(app)
end

function M:initGlobal(app)
  _G.Laravel = setmetatable({
    app = app,
    extensions = {},
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

function M:register(item, app, args)
  if item.register then
    local ok, res = pcall(function()
      item:register(app, args)
    end)

    if not ok then
      notify.error(string.format("Register Provider: %s. Error: %s", item.name or "(Name missing)", res))
    end
  end
end

function M:boot(item, app, args)
  if item.boot then
    local ok, res = pcall(function()
      item:boot(app, args)
    end)
    if not ok then
      notify.error(string.format("Boot Provider: %s. Error: %s", item.name or "(Name missing)", res))
    end
  end
end

function M:registerProviders(app)
  vim.tbl_map(function(provider)
    return M:register(provider, app)
  end, config.get("providers", {}))
end

function M:bootProviders(app)
  vim.tbl_map(function(provider)
    return M:boot(provider, app)
  end, config.get("providers", {}))
end

function M:registerUserProviders(app)
  vim.tbl_map(function(provider)
    return M:register(provider, app)
  end, config.get("user_providers", {}))
end

function M:bootUserProviders(app)
  vim.tbl_map(function(provider)
    return M:boot(provider, app)
  end, config.get("user_providers", {}))
end

function M:registerExtensions(app)
  vim.iter(config.get("extensions", {})):each(function(k, v)
    local ok, extension_provider = pcall(require, "laravel.extensions." .. k)
    if not ok then
      return notify.error(string.format("Error loading extension %s: %s", k, v))
    end
    if v.enable then
      extension_provider.name = k
      M:register(extension_provider, app, v)
    end
  end)
end

function M:bootExtensions(app)
  vim.iter(config.get("extensions", {})):each(function(k, v)
    local ok, extension_provider = pcall(require, "laravel.extensions." .. k)
    if not ok then
      return notify.error(string.format("Error loading extension %s: %s", k, v))
    end
    if v.enable then
      extension_provider.name = k
      M:boot(extension_provider, app, v)
    end
  end)
end

return M
