local run = require "laravel.run"
local utils = require "laravel.commands.utils"
local notify = require "laravel.notify"

local M = {}

M.list = {}

function M.load()
  local result, ok = run("artisan", { "list", "--format=json" }, { runner = "sync" })
  if not ok or result.exit_code == 1 then
    notify("Commands.Load", {
      msg = string.format("Failed to get commands %s %s", vim.inspect(result.out), vim.inspect(result.err)),
      level = "ERROR",
    })
    M.list = {}

    return false
  end

  M.list = utils.from_json(result.out)

  return true
end

return M
