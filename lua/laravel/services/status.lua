local nio = require("nio")
local health = require("laravel.core.health")

---@class laravel.services.status
---@field api laravel.services.api
---@field values table
---@field frequency number
local status = {}

local function setInterval(interval, callback)
  local timer = vim.uv.new_timer()
  assert(timer, "Failed to create timer")
  timer:start(interval, interval, vim.schedule_wrap(callback))

  return timer
end

function status:new(api)
  local instance = {
    api = api,
    frequency = 120,
    values = {
      php = nil,
      laravel = nil,
      health = nil,
    },
    refresh = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@async
function status:update()
  if self.refresh then
    self.refresh()
  end
end

---@async
function status:start()
  local refresh = nio.create(function()
    self.values.health = health.getStatus()

    local response, err = self.api:run("artisan about --json")
    if err or not response or type(response.failed) ~= "function" or response:failed() then
      self.values.health = health.getStatus()
      return
    end
    local info = response:json()
    if info and info.environment then
      self.values.laravel = info.environment.laravel_version
      self.values.php = info.environment.php_version
    end
    self.values.health = health.getStatus()
  end, 0)

  self.refresh = refresh

  setInterval(self.frequency * 1000, refresh)

  refresh()
end

---@return table|string|nil
function status:get(property)
  if property == nil then
    return self.values
  end

  if vim.tbl_contains(vim.tbl_keys(self.values), property) then
    return self.values[property]
  end

  return nil
end

function status:has(values)
  return self.values[values] ~= nil
end

return status
