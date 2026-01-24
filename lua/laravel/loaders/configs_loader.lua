local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local watcher = require("laravel.core.watcher")

---@class laravel.loaders.configs_loader
---@field code laravel.services.code
---@field path laravel.services.path
---@field loaded boolean
---@field items laravel.dto.artisan_views[]
local ConfigsLoader = Class({
  code = "laravel.services.code",
  path = "laravel.services.path",
}, { items = {}, loaded = false })

---@return laravel.dto.app_config[], laravel.error
function ConfigsLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local configs, err = self.code:fromTemplate("configs")
    if err or not configs then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load views"):wrap(err)
    end

    self.loaded = true
    self.items = configs or {}

    return self.items
  end

  local config_directory, err = self.path:get("config")
  if err then
    return {}, Error:new("Failed to get config path"):wrap(err)
  end

  watcher.register({ { config_directory, recursive = true } }, ".*.php$", _load)

  return _load()
end

function ConfigsLoader:get(name)
  local configs, err = self:load()
  if err then
    return nil, Error:new("Failed to load configs"):wrap(err)
  end

  ---@type laravel.dto.app_config|nil
  local config = vim.iter(configs):find(
    ---@param item laravel.dto.config
    function(item)
      return item.name == name
    end
  )
  if not config then
    return nil, Error:new(("Config not found: %s"):format(name))
  end

  return config
end

return ConfigsLoader

-- [
--   {
--     "name": "cors.paths",
--     "value": "array(...)",
--     "file": "vendor/laravel/framework/config/cors.php",
--     "line": 18
--   },
-- ]
