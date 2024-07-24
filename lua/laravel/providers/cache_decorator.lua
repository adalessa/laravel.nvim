local decorator = {}

function decorator:new(inner)
  local instance = {
    inner = inner,
    cache = nil,
    timeout = 60 * 1000
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function decorator:get(callback)
  if self.cache then
    callback(self.cache.res)

    return self.cache.value
  end

  self.cache = {
    value = self.inner:get(function(result)
      self.cache.res = result
      callback(result)
    end),
  }

  local timer = vim.loop.new_timer()
  timer:start(self.timeout, 0, function()
    timer:stop()
    timer:close()
    self.cache = nil
  end)

  return self.cache.value
end

return decorator
