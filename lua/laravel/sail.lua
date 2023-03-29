local runners = require "laravel.runners"

local sail = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
---@return table, boolean
sail.run = function(cmd, runner, opts)
  opts = opts or {}
  table.insert(cmd, 1, "vendor/bin/sail")
  runner = runner or require("laravel").app.options.default_runner

  return runners[runner](cmd, opts), true
end

--- checks if sail is running, simple way of taking the ps response and if it empty just return false
---@return boolean
sail.is_running = function()
  local res = sail.run({ "ps" }, "sync")

  return #res.out > 1
end

return sail
