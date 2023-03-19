local runners = require "laravel.runners"

local composer = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
composer.run = function(cmd, runner, opts)
  table.insert(cmd, 1, "composer")
  if require("laravel").app.environment.uses_sail then
    table.insert(cmd, 1, "vendor/bin/sail")
  end
  runner = runner or require("laravel").app.options.default_runner

  return runners[runner](cmd, opts or {})
end

return composer
