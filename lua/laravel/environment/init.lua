local config = require "laravel.config"
local user_commands = require "laravel.user_commands"

local M = {}

M.environment = {}

function M.setup()
  M.environment = config.options.environment.resolver(config.options.environment.environments)
  if type(M.environment) == "function" then
    M.environment = M.environment()
  end

  user_commands.setup()
  if config.options.route_info.enable then
    require("laravel.route_info").setup()
  end
end

---@param name string
---@return string[]|nil
function M.get_executable(name)
  local executable = M.environment.executables[name]
  if executable == nil then
    return nil
  end
  return executable
end

return M
