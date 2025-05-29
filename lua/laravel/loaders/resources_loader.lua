local Class = require("laravel.utils.class")

---@class laravel.loaders.resources_loader
---@field tinker laravel.services.tinker
local ResourcesLoader = Class({ tinker = "laravel.services.tinker" })

---@return string, string?
function ResourcesLoader:get(resource)
  resource = string.format("'%s'", resource) or ""

  local basePath, err = self.tinker:text("echo base_path();")
  if err then
    return "", "Failed to get base path: " .. err
  end
  local resourcePath, err = self.tinker:text(string.format("echo resource_path(%s);", resource))
  if err then
    return "", "Failed to get resource path: " .. err
  end

  basePath = vim.trim(basePath or "")
  resourcePath = vim.trim(resourcePath or "")

  local cwd = vim.uv.cwd()

  assert(cwd, "Current working directory is not set")

  local res, _ = resourcePath:gsub(basePath:gsub("-", "%%-"), cwd)

  return res
end

return ResourcesLoader
