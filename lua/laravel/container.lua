---@class LaravelContainer
---@field registry table<string, function|table>
---@field tags table<string, string[]>
local Container = {}

function Container:new()
  local instance = {
    registry = {},
    tags = {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function Container:set(name, item, opts)
  self.registry[name] = item
  opts = opts or {}

  for _, tag in ipairs(opts.tags or {}) do
    if not self.tags[tag] then
      self.tags[tag] = {}
    end

    table.insert(self.tags[tag], name)
  end
end

function Container:byTag(tag)
  return self.tags[tag] or {}
end

---@param name string
---@return object
function Container:get(name)
  if not self.registry[name] then
    error("Unknown service '" .. name .. "'")
  end

  return self.registry[name]
end

---@param name string
---@return boolean
function Container:has(name)
  return self.registry[name] ~= nil
end

return Container
