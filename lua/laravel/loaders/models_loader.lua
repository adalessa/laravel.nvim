local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local watcher = require("laravel.core.watcher")

local paths = {
  "app",
  "app/Models",
  "database/migrations",
}

---@class laravel.loaders.models_loader
---@field code laravel.services.code
local ModelsLoader = Class({
  code = "laravel.services.code",
}, { items = {}, loaded = false })

---@async
function ModelsLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local models, err = self.code:run("models")
    if err then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load models"):wrap(err)
    end

    self.loaded = true
    self.items = models or {}

    return self.items
  end

  watcher.register(paths, ".*.php$", _load)

  return _load()
end

-- should create a new entity that handle the cache
return ModelsLoader
