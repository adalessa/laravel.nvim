local notify = require("laravel.utils.notify")

local extension_provider = { name = "laravel.providers.extensions_provider" }

local function loadExtensions(name)
  local ok, ext_provider = pcall(require, string.format("laravel.extensions.%s.provider", name))
  if ok then
    return ext_provider
  end

  ok, ext_provider = pcall(require, string.format("laravel.extensions.%s", name))

  if ok then
    return ext_provider
  end

  return nil
end

local function iterateExtensions(extensions, callback)
  vim.iter(extensions):each(function(k, v)
    local provider = loadExtensions(k)
    if not provider then
      return notify.error(string.format("Error loading extension %s: %s", k, v))
    end
    if v.enable then
      provider.name = k
      callback(provider, v)
    end
  end)
end

---@param app laravel.core.app
function extension_provider:register(app)
  iterateExtensions(app("laravel.services.config").get("extensions", {}), function(provider, opts)
    if provider.register then
      local ok, res = pcall(function()
        provider:register(app, opts)
      end)

      if not ok then
        notify.error(string.format("Register Provider: %s. Error: %s", provider.name or "(Name missing)", res))
      end
    end
  end)
end

---@param app laravel.core.app
function extension_provider:boot(app)
  Laravel.extensions = {}

  iterateExtensions(app("laravel.services.config").get("extensions", {}), function(provider, opts)
    if provider.register then
      local ok, res = pcall(function()
        provider:boot(app, opts)
      end)

      if not ok then
        notify.error(string.format("Booting Provider: %s. Error: %s", provider.name or "(Name missing)", res))
      end
    end
  end)

end

return extension_provider
