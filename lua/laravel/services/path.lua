local Class = require("laravel.utils.class")

---@class laravel.services.path
---@field tinker laravel.services.tinker
local path_service = Class({
  tinker = "laravel.services.tinker",
}, { base_path = nil, cwd = nil })

---@param path string
function path_service:handle(path)
  if not self.base_path then
    self.base_path = self.tinker:text("echo base_path();")
    self.base_path = vim.trim(self.base_path or "")
    self.cwd = vim.uv.cwd()
  end
  if self.base_path == self.cwd then
    -- no modification necessary
    return path
  end

  path, _ = path:gsub(self.base_path:gsub("-", "%%-"), self.cwd)

  return path
end

return path_service
