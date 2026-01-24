local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local watcher = require("laravel.core.watcher")

local paths = {
  "app/Providers",
}

---@class laravel.loaders.paths_loader
---@field code laravel.services.code
local PathsLoader = Class({
  code = "laravel.services.code",
}, { items = {}, loaded = false })

---@async
---@return laravel.dto.paths_response, laravel.utils.error|nil
function PathsLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local result, err = self.code:fromTemplate("paths")
    if err then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load models"):wrap(err)
    end

    self.loaded = true
    self.items = result or {}

    return self.items
  end

  watcher.register(paths, ".*.php$", _load)

  return _load()
end

-- should create a new entity that handle the cache
return PathsLoader
