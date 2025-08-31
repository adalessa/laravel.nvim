local Error = require("laravel.utils.error")

---@class laravel.dto.environment
---@field name string
---@field map table<string, string[]>
local Environment = {}

local cache = {}

---@param env table
---@return laravel.dto.environment
function Environment:new(env)
  local instance = {
    name = env.name,
    map = env.map or {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param name string
---@return string[], laravel.error
function Environment:executable(name)
  if cache[name] then
    return cache[name]
  end

  local cmd = { name }
  if self.map[name] then
    cmd = self.map[name]
  end

  if vim.fn.executable(cmd[1]) == 0 then
    return {}, Error:new(string.format("Executable '%s' not found needed for %s", cmd[1], table.concat(cmd, " ")))
  end

  cache[name] = cmd

  return cmd
end

return Environment
