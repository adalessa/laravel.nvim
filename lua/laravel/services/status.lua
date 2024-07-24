---@class LaravelStatusService
---@field artisan LaravelArtisanService
---@field php LaravelPhpService
---@field values table
---@field frequency number
local status = {}

local function setInterval(interval, callback)
  local timer = vim.loop.new_timer()
  timer:start(interval, interval, function()
    callback()
  end)

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

  local refresh = function()
    instance.php:available(function(available)
      if available then
        instance.php:version(function(version)
          instance.values.php = version
        end)
      end
    end)
    instance.artisan:available(function(available)
      if available then
        instance.artisan:version(function(version)
          instance.values.laravel = version
        end)
      end
    end)
  end

  setInterval(instance.frequency * 1000, refresh)

  refresh()

  return instance
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
