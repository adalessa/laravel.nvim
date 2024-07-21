---@class LaravelStatusService
---@field artisan LaravelArtisanService
---@field php LaravelPhpService
---@field last_check number|nil
---@field values table
---@field frequency number
local status = {}

function status:new(artisan, php, frequency)
  local instance = setmetatable({}, { __index = status })
  instance.artisan = artisan
  instance.php = php

  instance.last_check = nil
  instance.frequency = frequency or 120

  instance.values = {
    php = nil,
    laravel = nil,
  }

  return instance
end

---@return table|string|nil
function status:get(property)
  self:_get_values()

  if property == nil then
    return self.values
  end

  if vim.tbl_contains(vim.tbl_keys(self.values), property) then
    return self.values[property]
  end

  return nil
end

function status:has(values)
  self:_get_values()

  return self.values[values] ~= nil
end

--- internal function don't use
function status:_get_values()
  if self.last_check and (self.last_check + self.frequency > os.time()) then
    return
  end

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

  self.last_check = os.time()
end

function status:refresh()
  self.last_check = nil
end

return status
