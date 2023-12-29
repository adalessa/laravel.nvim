local utils = require "laravel.commands.utils"
local api = require "laravel.api"

local M = {}

M.list = {}

function M.load()
  M.list = {}
  local result = api.sync("artisan", { "list", "--format=json" })
  if result:failed() then
    vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
    return false
  end

  M.list = utils.from_json(result.stdout)
end

return M
