local utils = require "laravel.routes.utils"
local api = require "laravel.api"

local M = {}

M.list = {}

function M.load()
  M.list = {}
  local result = api.sync("artisan", { "route:list", "--json" })
  if result:failed() then
    error(result:errors(), vim.log.levels.ERROR)
  end

  M.list = utils.from_json(result.stdout)

  return true
end

return M
