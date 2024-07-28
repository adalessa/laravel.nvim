local function get_args(func)
    local args = {}
    for i = 1, debug.getinfo(func).nparams, 1 do
        table.insert(args, debug.getlocal(func, i));
    end
    return args;
end

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
---@param factory function|string
function Container:register(name, factory)
  if type(factory) == "string" then
    local factoryName = factory
    factory = function()
      local module = require(factoryName)
      local constructor = module.new

      if not constructor then
        return module
      end

      local args = get_args(constructor)

      if #args > 1 then
        table.remove(args, 1)
        local arguments = {}
        for k, v in pairs(args) do
          arguments[k] = self:get(v)
        end

        return module:new(unpack(arguments))
      end

      return module:new()
    end
  end
  self.registry[name] = factory
  self.cont[name] = nil
end

function Container:register_many(services)
  for name, factory in pairs(services) do
    self:register(name, factory)
  end
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
