local notify = require("laravel.utils.notify")

---@param path string
---@return table|nil
local function parseExtension(path)
  -- nvim_get_runtime_file returns platform-specific separators, so normalize
  -- before splitting the path into a module and extension name.
  local normalized = path:gsub("\\", "/")
  local name = normalized:match("lua/laravel/extensions/([^/]+)/provider%.lua$")
  if not name then
    return nil
  end

  return {
    module = string.format("laravel.extensions.%s.provider", name),
    name = name,
  }
end

local function getExtensions()
  return vim
    .iter(vim.api.nvim_get_runtime_file("lua/laravel/extensions/*/provider.lua", true))
    :map(parseExtension)
    :filter(function(ext)
      return ext ~= nil
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
    local opts = app("options").get("extensions." .. ext.name, {})
    if opts.enable and provider.register then
      local ok, res = pcall(function()
        provider.register(app, opts)
        ext.registered = true
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
    local opts = app("options").get("extensions." .. ext.name, {})
    if opts.enable and provider.boot then
      local ok, res = pcall(function()
        provider.boot(app, opts)
        ext.booted = true
      end)

      if not ok then
        notify.error(string.format("Booting Provider: %s. Error: %s", provider.name or "(Name missing)", res))
      end
    end
  end)
end

return extension_provider
