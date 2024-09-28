local promise = require("promise")

---@class CacheConfigsRepository : ConfigsRespository
---@field configs_repository ConfigsRespository
---@field cache LaravelCache
---@field prefix string key to store the configs
---@field key string tag to store the configs
---@field timeout number seconds for the cache
local cache_configs_repository = {}

function cache_configs_repository:new(configs_repository, cache)
  local instance = {
    configs_repository = configs_repository,
    cache = cache,
    prefix = "laravel-config-",
    key = "laravel-configs",
    timeout = 60,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function cache_configs_repository:all()
  if self.cache:has(self.key) then
    return promise.resolve(self.cache:get(self.key))
  end

  return self.configs_repository:all():thenCall(
    function(views)
      self.cache:put(self.key, views, self.timeout)

      return views
    end
  )
end

---@param key string
---@return Promise
function cache_configs_repository:get(key)
  local cache_key = self.prefix .. key
  if self.cache:has(cache_key) then
    return promise.resolve(self.cache:get(cache_key))
  end

  return self.configs_repository:get(key):thenCall(
    function(config)
      self.cache:put(cache_key, config, self.timeout)
      return config
    end
  )
end

function cache_configs_repository:clear()
  self.cache:forget(self.key)
  self.cache:forgetByPrefix(self.prefix)
end

return cache_configs_repository
