local notify = require("laravel.utils.notify")
local function getExtensions()
  return vim
    .iter(vim.api.nvim_get_runtime_file("lua/laravel/extensions/*/provider.lua", true))
    :map(function(ext)
      local m = ext:match("lua/(.*)%.lua$"):gsub("/", ".")
      local name = m:match("laravel%.extensions%.(.*)%.provider")

      return {
        module = m,
        name = name,
      }
    end)
    :totable()
end

---@type laravel.providers.provider
local extension_provider = {
  name = "laravel.providers.extensions_provider",
  extensions = getExtensions(),
}

---@class laravel.extensions.provider : laravel.providers.provider
---@field register fun(app: laravel.core.app, opts: table): nil
---@field boot fun(app: laravel.core.app, opts: table): nil

---@param app laravel.core.app
function extension_provider.register(app)
  vim.iter(extension_provider.extensions):each(function(ext)
    local ok, provider = pcall(require, ext.module)
    if not ok then
      return
    end
    local opts = app("laravel.services.config").get("extensions." .. ext.name, {})
    if provider.register then
      local ok, res = pcall(function()
        provider.register(app, opts)
        ext.registered = true;
      end)

      if not ok then
        notify.error(string.format("Register Provider: %s. Error: %s", provider.name or "(Name missing)", res))
      end
    end
  end)
end

---@param app laravel.core.app
function extension_provider.boot(app)
  Laravel.extensions = {}

  vim.iter(extension_provider.extensions):each(function(ext)
    local ok, provider = pcall(require, ext.module)
    if not ok then
      return
    end
    local opts = app("laravel.services.config").get("extensions." .. ext.name, {})
    if provider.boot then
      local ok, res = pcall(function()
        provider.boot(app, opts)
        ext.booted = true;
      end)

      if not ok then
        notify.error(string.format("Booting Provider: %s. Error: %s", provider.name or "(Name missing)", res))
      end
    end
  end)
end

return extension_provider
