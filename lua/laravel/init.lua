local M = {}

---@param opts? LaravelOptions
function M.setup(opts)
  local config = require "laravel.config"
  local environment = require "laravel.environment"
  local autocmds = require "laravel.autocommands"

  config.setup(opts)
  autocmds.setup()

  if vim.fn.filereadable "artisan" ~= 0 then
    environment.setup()
  end
end

return M
