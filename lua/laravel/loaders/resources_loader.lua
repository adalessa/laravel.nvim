local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.loaders.resources_loader
---@field tinker laravel.services.tinker
local ResourcesLoader = Class({ tinker = "laravel.services.tinker" })

---@return string, laravel.error
function ResourcesLoader:get(resource)
  resource = string.format("'%s'", resource) or ""

  local basePath, err = self.tinker:text("echo base_path();")
  if err then
    return "", Error:new("Failed to get base path"):wrap(err)
  end

  local resourcePath, resourceError = self.tinker:text(("echo resource_path(%s);"):format(resource))
  if resourceError then
    return "", Error:new(("Failed to get resource resource:%s"):format(resource)):wrap(resourceError)
  end

  basePath = vim.trim(basePath or "")
  resourcePath = vim.trim(resourcePath or "")

  local cwd = vim.uv.cwd()

  assert(cwd, "Current working directory is not set")

  local res, _ = resourcePath:gsub(basePath:gsub("-", "%%-"), cwd)

  return res
end

return ResourcesLoader
