local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.views
---@field resources_loader laravel.loaders.resources_loader
---@field runner laravel.services.runner
local views = Class({
  resources_loader = "laravel.loaders.resources_loader",
  runner = "laravel.services.runner",
})

---@async
---@return string, laravel.error
function views:pathFromName(name)
  local views_directory, err = self.resources_loader:get("views")
  if err then
    return "", Error:new("Failed to get views directory"):wrap(err)
  end

  return string.format("%s/%s.blade.php", views_directory, name:gsub("%.", "/"))
end

---@async
---@return string, laravel.error
function views:nameFromPath(path)
  local views_directory, err = self.resources_loader:get("views")
  if err then
    return "", Error:new("Failed to get views directory"):wrap(err)
  end
  local name = path:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", "."):gsub("^%.", "")

  return name
end

return views
