local nio = require("nio")
---@class laravel.utils.log
---@field path string
---@field level vim.log.levels
local Log = {}

local level_text = {
  "DEBUG",
  "INFO",
  "WARN",
  "ERROR",
}

--- Create a new Log instance
---@param path string: The path to the log file
---@param level string: The minimum log level (default: "debug")
---@return laravel.utils.log
function Log:new(path, level)
  local instance = {
    path = path,
    level = level or vim.log.levels.DEBUG,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

--- Write a log entry to the file
---@param level vim.log.levels
---@param message string: The log message
Log.write = nio.create(function(self, level, message)
  if level < self.level then
    return
  end

  local entry = string.format("[%s] %s: %s\n", os.date("%Y-%m-%d %H:%M:%S"), level_text[level], message)

  nio.fn.mkdir(vim.fs.dirname(self.path), "p")

  ---@diagnostic disable-next-line: param-type-mismatch
  local file, err = nio.file.open(self.path, "a")
  if not file then
    error("Failed to open log file: " .. err)
  end

  file.write(entry)
  file.close()
end, 3)

--- Log a debug message
---@param message string: The debug message
function Log:debug(message)
  self:write(vim.log.levels.DEBUG, message)
end

--- Log an info message
-- @param message string: The info message
function Log:info(message)
  self:write(vim.log.levels.INFO, message)
end

--- Log a warning message
---@param message string: The warning message
function Log:warning(message)
  self:write(vim.log.levels.WARN, message)
end

--- Log an error message
---@param message string|laravel.utils.error: The error message or error instance
function Log:error(message)
  if type(message) == "table" and message.toString then
    message = message:toString()
  end
  self:write(vim.log.levels.ERROR, message)
end

return Log
