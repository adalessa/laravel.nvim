local Class = require("laravel.utils.class")

---@class laravel.services.views
---@field resources_loader laravel.loaders.resources_loader
---@field runner laravel.services.runner
local views = Class({
  resources_loader = "laravel.loaders.resources_loader",
  runner = "laravel.services.runner",
})

---@async
function views:pathFromName(name)
  local views_directory, err = self.resources_loader:get("views")
  if err then
    return "", "Failed to get views directory: " .. err
  end

  return string.format("%s/%s.blade.php", views_directory, name:gsub("%.", "/"))
end

---@async
function views:nameFromPath(path)
  local views_directory, err = self.resources_loader:get("views")
  if err then
    return "", "Failed to get views directory: " .. err
  end
  local name = path:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", "."):gsub("^%.", "")

  return name
end

return views
