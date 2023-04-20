local runners = require "laravel.runners"

local npm = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
---@return table, boolean
npm.run = function(cmd, runner, opts)
  opts = opts or {}
  table.insert(cmd, 1, "npm")

  local laravel = require("laravel").app
  local ok = laravel.if_uses_sail(function()
    cmd = laravel.buildCmd(laravel.options.exec.npm, cmd)
  end, nil, opts.silent or false)

  if not ok then
    return {}, false
  end

  runner = runner or laravel.options.default_runner

  return runners[runner](cmd, opts), true
end

return npm
