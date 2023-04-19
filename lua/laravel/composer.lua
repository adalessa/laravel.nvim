local runners = require "laravel.runners"

local composer = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
---@return table, boolean
composer.run = function(cmd, runner, opts)
  opts = opts or {}
  table.insert(cmd, 1, "composer")

  local laravel = require("laravel").app
  local ok = laravel.if_uses_sail(function()
    table.insert(cmd, 1, laravel.options.exec)
  end, nil, opts.silent or false)

  if not ok then
    return {}, false
  end

  runner = runner or laravel.options.default_runner

  return runners[runner](cmd, opts), true
end

return composer
