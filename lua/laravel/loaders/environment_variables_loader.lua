local Class = require("laravel.utils.class")
local split = require("laravel.utils.init").split
local nio = require("nio")
local Error = require("laravel.utils.error")

---@class laravel.loaders.environment_variables_loader
local EnvironmentVariablesLoader = Class()

---@class laravel.dto.environment_variable
---@field key string
---@field value string

---@return laravel.dto.environment_variable[], laravel.error
function EnvironmentVariablesLoader:load()
  local file = nio.file.open(".env")
  if not file then
    return {}, Error:new("No .env file found")
  end
  local content = file.read(nil, 0)
  if not content then
    return {}, Error:new("Failed to read .env file")
  end

  return vim
    .iter(vim.split(content, "\n"))
    :filter(function(line)
      return line ~= "" and not vim.startswith(line, "#")
    end)
    :map(function(line)
      local spl = split(line, "=")

      return {
        key = spl[1],
        value = spl[2],
      }
    end)
    :totable()
end

return EnvironmentVariablesLoader
