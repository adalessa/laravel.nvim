local promise = require("promise")

---@class LaravelStatusService
---@field artisan LaravelArtisanService
---@field php LaravelPhpService
---@field values table
---@field frequency number
local status = {}

local function setInterval(interval, callback)
  local timer = vim.uv.new_timer()
  timer:start(interval, interval, vim.schedule_wrap(callback))

  return timer
end

function status:new(artisan, php, frequency)
  local instance = {
    artisan = artisan,
    php = php,
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
    promise
        .all({
          self.php:version(),
          self.artisan:version(),
        })
        :thenCall(function(resp)
          self.values.php = resp[1]
          self.values.laravel = resp[2]
        end)
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