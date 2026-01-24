local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.dto.artisan_views
---@field key string
---@field path string
---@field isVendor boolean

---@class laravel.loaders.views_loader
---@field code laravel.services.code
local ViewsLoader = Class({
  code = "laravel.services.code",
})

---@return laravel.dto.artisan_views[], laravel.error
function ViewsLoader:load()
  local views, err = self.code:fromTemplate("views")
  if err then
    return {}, Error:new("Failed to load views"):wrap(err)
  end

  return views or {}
end

return ViewsLoader
