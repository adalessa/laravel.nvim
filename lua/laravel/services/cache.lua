---@class LaravelCache
local cache = {}

function cache:new()
  local instance = {
    store = {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function cache:get(key, default)
  if not self:has(key) then
    return default
  end

  return self.store[key].value
end

---@param key string
---@return boolean
function cache:has(key)
  return self.store[key] ~= nil
end

-- need to think a way to handle the callback ones.

function cache:put(key, value, seconds)
  if self:has(key) then
    local timer = self.store[key].timer
    if timer then
      timer:stop()
      timer:close()
    end
  end

  self.store[key] = {
    value = value,
    seconds = seconds,
    timer = nil,
  }
  if seconds then
    local timer = vim.uv.new_timer()
    timer:start(seconds * 1000, 0, function()
      self.store[key] = nil
      timer:stop()
      timer:close()
    end)

    self.store[key].timer = timer
  end

  return self.store[key]
end

function cache:forever(key, value)
  return self:put(key, value)
end

-- only add if key does not exist
function cache:add(key, value, seconds)
  if self:has(key) then
    return false
  end
  self:put(key, value, seconds)
  return true
end

function cache:remember(key, seconds, callback)
  if self:has(key) then
    return self:get(key)
  end

  local value = callback()
  self:put(key, value, seconds)

  return value
end

function cache:rememberForever(key, callback)
  return self:remember(key, nil, callback)
end

function cache:pull(key, default)
  if self:has(key) then
    local value = self:get(key)
    self:forget(key)
    return value
  end

  return default
end

function cache:forget(key)
  self.store[key] = nil
end

function cache:flush()
  self.store = {}
end

return cache
