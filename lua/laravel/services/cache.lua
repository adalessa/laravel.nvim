local Class = require("laravel.utils.class")

---@class laravel.services.cache
---@field store table<string, any>
local cache = Class(nil, {store = {}})

---@param key string
---@param default any
---@return any
function cache:get(key, default)
  return self:has(key) and self.store[key].value or default
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
    if not timer then
      error("Failed to create timer")
    end

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

---@param key string
---@param seconds number|nil
---@param callback fun(): (any, laravel.error)
---@return any, laravel.error
function cache:remember(key, seconds, callback)
  if self:has(key) then
    return self:get(key)
  end

  local value, err = callback()
  if not err then
    self:put(key, value, seconds)
  end

  return value, err
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

function cache:forgetByPrefix(prefix)
  for key, _ in pairs(self.store) do
    if key:find(prefix) == 1 then
      self:forget(key)
    end
  end
end

function cache:flush()
  self.store = {}
end

return cache
