local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local watcher = require("laravel.core.watcher")

---@class laravel.dto.artisan_views
---@field key string
---@field path string
---@field isVendor boolean
---@field isLivewire boolean

---@class laravel.loaders.views_loader
---@field code laravel.services.code
---@field path laravel.services.path
---@field loaded boolean
---@field items laravel.dto.artisan_views[]
local ViewsLoader = Class({
  code = "laravel.services.code",
  path = "laravel.services.path",
}, { items = {}, loaded = false })

---@return laravel.dto.artisan_views[], laravel.error
function ViewsLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local views, err = self.code:fromTemplate("views")
    if err or not views then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load views"):wrap(err)
    end

    self.loaded = true
    self.items = views or {}

    return self.items
  end

  local views_directory, err = self.path:get("views")
  if err then
    return {}, Error:new("Failed to get views path"):wrap(err)
  end

  watcher.register({ { views_directory, recursive = true } }, ".*.blade.php$", _load)

  return _load()
end

return ViewsLoader

-- Example output:
-- [
--   {
--     "path": "resources/views/livewire/app.blade.php",
--     "isVendor": false,
--     "key": "app",
--     "isLivewire": true
--   },
-- ]
