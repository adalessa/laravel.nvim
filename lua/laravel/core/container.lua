---@class laravel.core.container
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

---@param name string
---@param item function|table
---@param opts table|nil
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

---@param tag string
---@return string[]
function Container:byTag(tag)
  return self.tags[tag] or {}
end

---@param name string
---@return any
function Container:get(name)
  if self.registry[name] then
    return self.registry[name]
  end

  return nil
end

---@param name string
---@return boolean
function Container:has(name)
  return self.registry[name] ~= nil
end

return Container
