---@class LaravelContainer
---@field registry table<string, function|table>
local Container = {}

function Container:new()
  local instance = setmetatable({}, { __index = Container })
  instance.registry = {}
  instance.cont = {}
  return instance
end

function Container:set(name, item)
  self.registry[name] = item
end

---@param name string
---@return object
function Container:get(name)
  if not self.registry[name] then
    error("Unknown service '" .. name .. "'")
  end

  return  self.registry[name]
end

---@param name string
---@return boolean
function Container:has(name)
  return self.registry[name] ~= nil
end

return Container
