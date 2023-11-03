local utils = require "laravel.commands.utils"
local api = require "laravel.api"

local M = {}

M.list = {}

function M.load()
  M.list = {}
  local result = api.sync("artisan", { "list", "--format=json" })
  if result.exit_code == 1 then
    error(
      string.format("Failed to get commands %s %s", vim.inspect(result.stdout), vim.inspect(result.stderr)),
      vim.log.levels.ERROR
    )
  end

  M.list = utils.from_json(result.stdout)
end

return M
