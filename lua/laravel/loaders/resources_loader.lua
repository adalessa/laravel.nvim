local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.loaders.resources_loader
---@field tinker laravel.services.tinker
---@field path laravel.services.path
local ResourcesLoader = Class({
  tinker = "laravel.services.tinker",
  path = "laravel.services.path",
})

---@return string, laravel.error
function ResourcesLoader:get(resource)
  resource = string.format("'%s'", resource) or ""

  local resourcePath, resourceError = self.tinker:text(("echo resource_path(%s);"):format(resource))
  if resourceError then
    return "", Error:new(("Failed to get resource resource:%s"):format(resource)):wrap(resourceError)
  end

  return self.path:handle(vim.trim(resourcePath))
end

return ResourcesLoader
