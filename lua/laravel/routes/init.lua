local utils = require "laravel.routes.utils"
local api = require "laravel.api"

local M = {}

M.list = {}

function M.load()
  M.list = {}
  local result = api.sync("artisan", { "route:list", "--json" })
  if result.exit_code == 1 then
    error(
      string.format(
        "Failed to get routes check your code %s %s",
        vim.fn.join(result.stdout, "\r\n"),
        vim.fn.join(result.stderr, "\r\n")
      ),
      vim.log.levels.ERROR
    )
  end

  M.list = utils.from_json(result.stdout)

  return true
end

return M
