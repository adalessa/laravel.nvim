local Error = require("laravel.utils.error")

---@class laravel.services.tinker
---@field api laravel.services.api
local tinker = {}

function tinker:new(api)
  local instance = { api = api }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return laravel.dto.apiResponse, laravel.error
function tinker:raw(code)
  local response, error = self.api:run("artisan", { "tinker", "--execute", code })

  if error then
    return {}, error
  end

  local pattern = "\n%s+Error"
  if response:content():find(pattern) then
    return {}, Error:new(response:content())
  else
    return response
  end
end

---@return string, laravel.error
function tinker:text(code)
  local response, err = self:raw(code)

  if err or not response then
    return "", err
  end

  return response:content()
end

---@return table, laravel.error
function tinker:json(code)
  local response, err = self:raw(code)

  if err or not response then
    return {}, err
  end

  return response:json()
end

return tinker
