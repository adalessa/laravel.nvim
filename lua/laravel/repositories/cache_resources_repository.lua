local promise = require("promise")

---@class CacheResourcesRepository : ResourcesRepository
---@field resources_repository ResourcesRepository
---@field cache laravel.services.cache
---@field prefix string key to store
---@field timeout number seconds
local cache_resources_repository = {}

function cache_resources_repository:new(resources_repository, cache)
  local instance = {
    resources_repository = resources_repository,
    cache = cache,
    prefix = "laravel-config-",
    timeout = 60,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param key string
---@return Promise
function cache_resources_repository:get(key)
  local cache_key = self.prefix .. key
  if self.cache:has(cache_key) then
    return promise.resolve(self.cache:get(cache_key))
  end

  return self.resources_repository:get(key):thenCall(
    function(config)
      self.cache:put(cache_key, config, self.timeout)
      return config
    end
  )
end

function cache_resources_repository:clear()
  self.cache:forgetByPrefix(self.prefix)
end

return cache_resources_repository
