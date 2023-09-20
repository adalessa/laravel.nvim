local run = require "laravel.run"
local notify = require "laravel.notify"
local utils = require "laravel.routes.utils"

local M = {}

M.list = {}

function M.load()
  local result, ok = run("artisan", { "route:list", "--json" }, { runner = "sync" })
  if not ok or result.exit_code == 1 then
    notify(
      "Routes.Load",
      { msg = string.format("Failed to get routes %s %s", result.out, result.err), level = "ERROR" }
    )
    M.list = {}

    return false
  end

  M.list = utils.from_json(result.out)

  return true
end

return M
