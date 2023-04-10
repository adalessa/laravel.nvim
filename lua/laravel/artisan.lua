local runners = require "laravel.runners"

local artisan = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table | nil
---@return table, boolean
artisan.run = function(cmd, runner, opts)
  opts = opts or {}
  runner = runner
    or require("laravel").app.options.commands_runner[cmd[1]]
    or require("laravel").app.options.default_runner

  table.insert(cmd, 1, "artisan")

  local ok = require("laravel").app.if_uses_sail(function()
    table.insert(cmd, 1, "vendor/bin/sail")
  end, function()
    table.insert(cmd, 1, "php")
  end, opts.silent or false)

  if not ok then
    return {}, false
  end

  -- TODO: when run artisan I want to store the term_id so Ican send
  -- commands or lines directly to tinker and get that executed

  return runners[runner](cmd, opts), true
end

return artisan
