local runners = require "laravel.runners"

local yarn = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
yarn.run = function(cmd, runner, opts)
  table.insert(cmd, 1, "yarn")
  if require("laravel").app.environment.uses_sail then
    table.insert(cmd, 1, "vendor/bin/sail")
  end
  runner = runner or require("laravel").app.options.default_runner

  return runners[runner](cmd, opts or {})
end

return yarn
