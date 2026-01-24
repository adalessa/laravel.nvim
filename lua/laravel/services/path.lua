local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.path
---@field loader laravel.loaders.paths_loader
local path_service = Class({
  loader = "laravel.loaders.paths_loader",
}, {})

---@param name string
---@return string, laravel.utils.error|nil
function path_service:get(name)
  local paths, err = self.loader:load()

  if err then
    return "", Error:new("Failed to load paths"):wrap(err)
  end

  if not paths[name] then
    return "", Error:new(("Path not found in loader: %s"):format(name))
  end

  return self:handle(paths[name])
end

---@param path string
---@return string, laravel.utils.error|nil
function path_service:handle(path)
  local cwd = vim.uv.cwd()

  if not cwd or cwd == "" then
    return path, nil
  end

  local paths, err = self.loader:load()

  if err then
    return "", Error:new("Failed to load paths"):wrap(err)
  end

  if cwd == paths.base then
    return path
  end

  local p = path:gsub(paths.base:gsub("-", "%%-"), cwd)

  return p, nil
end

return path_service
