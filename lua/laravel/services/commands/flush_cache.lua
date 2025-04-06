local flush_cache = {}

function flush_cache:new(cache)
  local instance = {
    cache = cache,
    command = "flush_cache",
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function flush_cache:handle()
  self.cache:flush()
  vim.api.nvim_exec_autocmds("User", {
    pattern = "LaravelFlushCache",
  })
end

return flush_cache
