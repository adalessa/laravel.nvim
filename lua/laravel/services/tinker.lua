---@class laravel.services.tinker
---@field api laravel.services.api
local tinker = {}

function tinker:new(api)
  local instance = { api = api }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function tinker:raw(code)
  local response = self.api:run("artisan", { "tinker", "--execute", code })

  local pattern = "\n%s+Error"
  if response:content():find(pattern) then
    return nil, response:content()
  else
    return response
  end
end

---@return string?, string?
function tinker:text(code)
  local response, err = self:raw(code)

  if err or not response then
    return nil, err
  end

  return response:content()
end

---@return table, string?
function tinker:json(code)
  local response, err = self:raw(code)

  if err or not response then
    return {}, err
  end

  return response:json()
end

return tinker
