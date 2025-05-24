---@class laravel.services.options
---@field opts LaravelOptions
local options = {}

function options:new(opts)
  local instance = {
    opts = opts or {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param key string|nil key with dot format
---@param default any default value if key is not found
---@return any
function options:get(key, default)
  if not key then
    return self.opts
  end

  local value = self.opts
  for _, seg in ipairs(vim.split(key, "%.")) do
    if type(value) ~= "table" then
      return default
    end
    value = value[seg]
  end

  return value or default
end

return options
