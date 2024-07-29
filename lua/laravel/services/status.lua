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
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function status:start()
  local refresh = function()
    self.php:available(function(available)
      if available then
        self.php:version(function(version)
          self.values.php = version
        end)
      end
    end)
    self.artisan:available(function(available)
      if available then
        self.artisan:version(function(version)
          self.values.laravel = version
        end)
      end
    end)
  end

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
