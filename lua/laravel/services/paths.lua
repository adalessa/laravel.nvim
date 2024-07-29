---@class LaravelPathProvider
---@field api LaravelApi
local path = {}

---@param api LaravelApi
function path:new(api)
  local instance = setmetatable({}, { __index = path })
  instance.api = api
  return instance
end

---@param callback fun(path: string)
---@return Job
function path:base(callback)
  return self.api:tinker("base_path()", function(response)
    if response:failed() then
      -- TODO: add log
      return
    end

    local base_path = response:first()
    assert(base_path, "Erro getting the base path")

    return callback(base_path)
  end)
end

---@param callback fun(commands: string)
---@return Job
function path:resource(resource, callback)
  return self.api:tinker(string.format("resource_path('%s')", resource), function(response)
    self:base(function(base_path)
      local cwd = vim.loop.cwd()
      if not cwd then
        -- TODO: add log
        return
      end
      callback(response:first():gsub(base_path:gsub("-", "%%-"), cwd))
    end)
  end)
end

return path