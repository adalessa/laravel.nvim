local promise = require("promise")

---@class CacheViewsRepository : ViewsRepository
---@field views_repository ViewsRepository
---@field cache laravel.service.cache
---@field key string key to store the commands
---@field timeout number seconds for the cache
local cache_views_repository = {}

function cache_views_repository:new(views_repository, cache)
  local instance = {
    views_repository = views_repository,
    cache = cache,
    key = "laravel-views",
    timeout = 60,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function cache_views_repository:all()
  if self.cache:has(self.key) then
    return promise.resolve(self.cache:get(self.key))
  end

  return self.views_repository:all():thenCall(
    function(views)
      self.cache:put(self.key, views, self.timeout)

      return views
    end
  )
end

function cache_views_repository:clear()
  self.cache:forget(self.key)
end

return cache_views_repository
