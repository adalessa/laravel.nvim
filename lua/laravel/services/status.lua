---@class LaravelStatusService
---@field api laravel.api
---@field values table
---@field frequency number
local status = {}

local function setInterval(interval, callback)
  local timer = vim.uv.new_timer()
  assert(timer, "Failed to create timer")
  timer:start(interval, interval, vim.schedule_wrap(callback))

  return timer
end

function status:new(api, frequency)
  local instance = {
    api = api,
    frequency = frequency or 120,
    values = {
      php = nil,
      laravel = nil,
    },
    refresh = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function status:update()
  if self.refresh then
    self.refresh()
  end
end

function status:start()
  local refresh = function()
    self.api
      :send("artisan", { "about", "--json" })
      :thenCall(function(response)
        return response:json()
      end)
      :thenCall(function(info)
        if not info then
          return
        end
        self.values.laravel = info.environment.laravel_version
        self.values.php = info.environment.php_version
      end)
      :catch(function() end)
  end

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
