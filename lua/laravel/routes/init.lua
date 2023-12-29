local utils = require "laravel.routes.utils"
local api = require "laravel.api"

local M = {}

M.list = {}

function M.load()
  M.list = {}
  local result = api.sync("artisan", { "route:list", "--json" })
  if result:failed() then
    vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
    return false
  end

  M.list = utils.from_json(result.stdout)

  return true
end

return M
