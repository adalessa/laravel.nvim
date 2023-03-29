local runners = require "laravel.runners"

local yarn = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
yarn.run = function(cmd, runner, opts)
  opts = opts or {}
  table.insert(cmd, 1, "yarn")

  local ok = require("laravel").app.if_uses_sail(function()
    table.insert(cmd, 1, "vendor/bin/sail")
  end, nil, opts.silent or false)

  if not ok then
    return {}, false
  end

  runner = runner or require("laravel").app.options.default_runner

  return runners[runner](cmd, opts or {})
end

return yarn
