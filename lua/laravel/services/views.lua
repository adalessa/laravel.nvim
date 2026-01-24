local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.views
---@field path_service laravel.services.path
---@field runner laravel.services.runner
local views = Class({
  path_service = "laravel.services.path",
  runner = "laravel.services.runner",
})

---@async
---@return string, laravel.error
function views:pathFromName(name)
  local views_directory, err = self.path_service:get("views")
  if err then
    return "", Error:new("Failed to get views directory"):wrap(err)
  end

  return string.format("%s/%s.blade.php", views_directory, name:gsub("%.", "/"))
end

---@async
---@return string, laravel.error
function views:nameFromPath(path)
  local views_directory, err = self.path_service:get("views")
  if err then
    return "", Error:new("Failed to get views directory"):wrap(err)
  end
  local name = path:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", "."):gsub("^%.", "")

  return name
end

return views
