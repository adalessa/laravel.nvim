local promise = require("promise")

---@class Tinker
---@field api LaravelApi
local tinker = {}

function tinker:new(api)
  local instance = { api = api }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function tinker:raw(code)
  return self.api:send("artisan", { "tinker", "--execute", code }):thenCall(
  ---@param response ApiResponse
    function(response)
      local pattern = "\n%s+Error"
      if response:content():find(pattern) then
        return promise.reject(response:content())
      else
        return response
      end
    end
  )
end

---@return Promise
function tinker:text(code)
  return self:raw(code):thenCall(function(response)
    return response:content()
  end)
end

---@return Promise
function tinker:json(code)
  return self:raw(code):thenCall(function(response)
    return response:json()
  end)
end

return tinker
