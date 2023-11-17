local config = require "laravel.config"
local user_commands = require "laravel.user_commands"

local M = {}

M.environment = {}

function M.setup()
  M.environment = {}
  if vim.fn.filereadable "artisan" == 0 then
    return
  end

  M.environment = config.options.environment.resolver(config.options.environment.environments)
  if type(M.environment) == "function" then
    M.environment = M.environment()
  end

  user_commands.setup()
  if config.options.features.route_info.enable then
    require("laravel.route_info").setup()
  end

  if config.options.features.null_ls.enable then
    require("laravel.null_ls").setup()
  end
end

---@param name string
---@return string[]|nil
function M.get_executable(name)
  if vim.tbl_isempty(M.environment) then
    return nil
  end
  local executable = M.environment.executables[name]
  if executable == nil then
    return nil
  end
  return executable
end

return M
