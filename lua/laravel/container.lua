---@class LaravelContainer
---@field registry table<string, function>
---@field cont table<string, object>
local Container = {}

function Container:new()
  local instance = setmetatable({}, { __index = Container })
  instance.registry = {}
  instance.cont = {}
  return instance
end

---@param name string
---@param factory function
function Container:register(name, factory)
  self.registry[name] = factory
  self.cont[name] = nil
end

---@param name string
---@return object
function Container:get(name)
  if not self.registry[name] then
    error("Unknown service '" .. name .. "'")
  end
  if self.cont[name] then
    return self.cont[name]
  end

  local factory = self.registry[name]
  local instance = factory()
  self.cont[name] = instance

  return instance
end

---@param name string
---@return boolean
function Container:has(name)
  return self.registry[name] ~= nil
end

return Container
