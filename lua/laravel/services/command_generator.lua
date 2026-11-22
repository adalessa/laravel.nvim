local combine_tables = require("laravel.utils.init").combine_tables
local Class = require("laravel.utils.class")

---@class laravel.services.command_generator
---@field new fun(self: laravel.services.command_generator, env: laravel.core.env): laravel.services.command_generator
---@field env laravel.core.env
local generator = Class({ env = "laravel.core.env" })

---@param name string
---@param args string[]|nil
---@return string[]|false, laravel.error
function generator:generate(name, args)
  local parts = vim.split(name, " ")
  name = table.remove(parts, 1)
  args = combine_tables(parts, args or {})

  local executable, err = self.env:getExecutable(name)
  if err or not executable then
    return false, err
  end

  return combine_tables(executable, args)
end

return generator
