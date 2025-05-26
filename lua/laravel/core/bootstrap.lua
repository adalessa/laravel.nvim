local config = require("laravel.services.config")

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
  _G.Laravel = {
    app = app,
    extensions = {},
  }
end

function M:register(item, app)
  if item.register then
    local ok, res = pcall(function()
      item:register(app)
    end)

    if not ok then
      vim.notify(
        string.format("Register Provider: %s. Error: %s", item.name or "(Name missing)", res),
        vim.log.levels.ERROR
      )
    end
  end
end

function M:boot(item, app)
  if item.boot then
    local ok, res = pcall(function()
      item:boot(app)
    end)
    if not ok then
      vim.notify(
        string.format("Booting Provider: %s. Error: %s", item.name or "(Name missing)", res),
        vim.log.levels.ERROR
      )
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
      vim.notify("Error loading extension " .. k .. ": " .. v, vim.log.levels.ERROR)
      return
    end
    if v.enable then
      extension_provider.name = k
      M:register(extension_provider, app)
    end
  end)
end

function M:bootExtensions(app)
  vim.iter(config.get("extensions", {})):each(function(k, v)
    local ok, extension_provider = pcall(require, "laravel.extensions." .. k)
    if not ok then
      vim.notify("Error loading extension " .. k .. ": " .. v, vim.log.levels.ERROR)
      return
    end
    if v.enable then
      extension_provider.name = k
      M:boot(extension_provider, app)
    end
  end)
end

return M
