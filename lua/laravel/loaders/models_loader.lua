local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

local paths = {
  "app",
  "app/Models",
  "database/migrations",
}

---@class laravel.loaders.models_loader
---@field code laravel.services.code
---@field config laravel.services.config
---@field eloquent_helper laravel.services.eloquent_helper
---@field watcher laravel.core.watcher
local ModelsLoader = Class({
  code = "laravel.services.code",
  config = "laravel.services.config",
  eloquent_helper = "laravel.services.eloquent_helper",
  watcher = "laravel.core.watcher",
}, { items = {}, loaded = false })

---@async
---@return laravel.dto.models_response, laravel.error
function ModelsLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    ---@type laravel.dto.models_response|nil
    local models, err = self.code:fromTemplate("models")
    if err or not models then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load models"):wrap(err)
    end

    self.loaded = true
    self.items = models or {}

    if self.config.get("eloquent_generate_doc_blocks") then
      self.eloquent_helper.write_eloquent_docblocks(models.models, models.builderMethods)
    end

    return self.items
  end

  self.watcher.register(paths, ".*.php$", _load)

  return _load()
end

-- should create a new entity that handle the cache
return ModelsLoader
