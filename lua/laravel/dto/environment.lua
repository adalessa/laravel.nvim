local Error = require("laravel.utils.error")

---@class laravel.dto.environment
---@field name string
---@field map table<string, string[]>
local Environment = {}

---@param env table
---@return laravel.dto.environment
function Environment:new(env)
  local instance = {
    name = env.name,
    map = env.map or {},
    -- Cache per environment. A module level cache would hand executables from
    -- one project/environment to the next when the working directory changes.
    cache = {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param name string
---@return string[], laravel.error
function Environment:executable(name)
  if self.cache[name] then
    return self.cache[name]
  end

  local cmd = { name }
  if self.map[name] then
    cmd = self.map[name]
  end

  if vim.fn.executable(cmd[1]) == 0 then
    return {}, Error:new(string.format("Executable '%s' not found needed for %s", cmd[1], table.concat(cmd, " ")))
  end

  self.cache[name] = cmd

  return cmd
end

return Environment
