local promise = require("promise")

---@class ResourcesRepository
---@field tinker Tinker
local resources_repository = {}

function resources_repository:new(tinker)
  local instance = { tinker = tinker }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param resource string
---@return Promise
function resources_repository:get(resource)
  local name = ''
  if resource then
    name = string.format("'%s'", resource)
  else
    name = '';
  end
  return promise.all({
    self.tinker:text("echo base_path();"),
    self.tinker:text(string.format("echo resource_path(%s);", name)),
  }):thenCall(function(results)
      local base_path, resource_path = unpack(vim.tbl_map(vim.trim, results))
      local cwd = vim.uv.cwd()

      local res, _ = resource_path:gsub(base_path:gsub("-", "%%-"), cwd)

      return res
  end)
end

return resources_repository
