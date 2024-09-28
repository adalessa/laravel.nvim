local promise = require("promise")

---@class CacheCommandsRepository : CommandsRepository
---@field commands_repository CommandsRepository
---@field cache LaravelCache
---@field key string key to store the commands
---@field timeout number seconds for the cache
local cache_commands_repository = {}

function cache_commands_repository:new(commands_repository, cache)
  local instance = {
    commands_repository = commands_repository,
    cache = cache,
    key = "laravel-commands",
    timeout = 60,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function cache_commands_repository:all()
  if self.cache:has(self.key) then
    return promise.resolve(self.cache:get(self.key))
  end

  return self.commands_repository:all():thenCall(function(commands)
    self.cache:put(self.key, commands, self.timeout)

    return commands
  end)
end

function cache_commands_repository:clear()
  self.cache:forget(self.key)
end

return cache_commands_repository
