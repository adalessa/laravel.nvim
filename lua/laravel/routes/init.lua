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

function M.asyncLoad(callback)
  api.async("artisan", { "route:list", "--json" }, function(result)
    if result:successful() then
      M.list = utils.from_json(result.stdout)
    end
    if callback ~= nil then
      callback(result)
    end
  end)
end

return M
