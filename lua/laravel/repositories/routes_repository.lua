local split = require("laravel.utils.init").split

---@class RoutesRepository
---@field api laravel.services.api
local routes_repository = {}

function routes_repository:new(api)
  local instance = { api = api }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function routes_repository:all()
  return self.api:send("artisan", { "route:list", "--json" }):thenCall(
  ---@param result laravel.dto.apiResponse
    function(result)
      return vim
          .iter(result:json() or {})
          :map(function(route)
            local controller = nil
            local method = nil

            local parts = split(route.action, "@")
            if #parts == 2 then
              controller = parts[1]
              method = parts[2]
            end

            return {
              uri = route.uri,
              action = route.action,
              controller = controller,
              method = method,
              domain = route.domain,
              methods = split(route.method, "|"),
              middlewares = route.middleware,
              name = route.name,
            }
          end)
          :totable()
    end
  )
end

return routes_repository
