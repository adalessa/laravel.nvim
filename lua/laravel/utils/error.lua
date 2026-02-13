---@alias laravel.error laravel.utils.error|nil

---@class laravel.utils.error
---@field message string: The error message
---@field file string?: The file where the error occurred (optional)
---@field line number?: The line where the error occurred (optional)
--- @field inner laravel.utils.error?: The wrapped error (optional)
local Error = {}

--- Create a new Error instance
--- @param message string The error message
--- @return laravel.utils.error The new error instance
function Error:new(message)
  local info = debug.getinfo(2, "Sl")
  local instance = {
    message = message,
    file = info.short_src, -- Dynamically retrieved file
    line = info.currentline, -- Dynamically retrieved line
    inner = nil, -- Wrapped error
  }
  setmetatable(instance, self)
  self.__index = self
  self.__tostring = function(err)
    return err:toString()
  end
  return instance
end

--- Wrap another error instance
-- @param inner Error: The error to wrap
-- @return Error: The current instance with the wrapped error
function Error:wrap(inner)
  self.inner = inner
  return self
end

--- Generate a human-readable string representation of the error
-- @return string: The error details
function Error:toString()
  local details = self.message
  if self.file and self.line then
    details = details .. string.format("\nOccured at: %s:%d", self.file, self.line)
  elseif self.file then
    details = details .. string.format("\nOccured at: %s", self.file)
  end
  if self.inner then
    details = details .. "\nCaused by: " .. self.inner:toString()
  end
  return details
end

return Error

