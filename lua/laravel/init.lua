local M = {}

---@param opts? LaravelOptions
function M.setup(opts)
  local config = require "laravel.config"
  local environment = require "laravel.environment"
  local autocmds = require "laravel.autocommands"

  config.setup(opts)
  autocmds.setup()
  environment.setup()
end

return M
