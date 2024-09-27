---@class LaravelConfigsCacheDecorator : LaravelConfigsProvider
---@field inner LaravelConfigsProvider
---@field cache LaravelCache
---@field timeout integer
---@field key string
---@field keyFormat string
local configs_cache_decorator = {}

function configs_cache_decorator:new(configs, cache)
  local instance = {
    inner = configs,
    cache = cache,
    timeout = 60,
    key = "app-configs",
    keyFormat = "app-config-%s"
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function configs_cache_decorator:keys(callback)
  if self.cache:has(self.key) then
    local item = self.cache:get(self.key, {response = {}, value = nil})
    callback(item.response)

    return item.value
  end

  local item = {}
  item.value = self.inner:keys(function(configs)
    item.response = configs
    self.cache:put(self.key, item, self.timeout)
    callback(configs)
  end)

  return item.value
end

function configs_cache_decorator:get(key, callback)
  return self.inner:get(key, callback)
end

function configs_cache_decorator:forget()
  self.cache:forget(self.key)
end

return configs_cache_decorator
