local promise = require("promise")

---@class CacheRoutesRepository : RoutesRepository
---@field routes_repository RoutesRepository
---@field cache laravel.services.cache
---@field key string key to store the commands
---@field timeout number seconds for the cache
local cache_routes_repository = {}

function cache_routes_repository:new(routes_repository, cache)
  local instance = {
    routes_repository = routes_repository,
    cache = cache,
    key = "laravel-routes",
    timeout = 60,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function cache_routes_repository:all()
  if self.cache:has(self.key) then
    return promise.resolve(self.cache:get(self.key))
  end

  return self.routes_repository:all():thenCall(
    function(routes)
      self.cache:put(self.key, routes, self.timeout)

      return routes
    end
  )
end

function cache_routes_repository:clear()
  self.cache:forget(self.key)
end

return cache_routes_repository
