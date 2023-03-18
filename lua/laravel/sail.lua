local runners = require("laravel.runners")

local sail = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
sail.run = function(cmd, runner, opts)
  table.insert(cmd, 1, "vendor/bin/sail")
  runner = runner or require("laravel").app.options.default_runner

  return runners[runner](cmd, opts or {})
end

return sail
