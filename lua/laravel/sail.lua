local runners = require "laravel.runners"

local sail = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
---@return table, boolean
sail.run = function(cmd, runner, opts)
  opts = opts or {}
  local laravel = require("laravel").app
  cmd = laravel.buildCmd(laravel.options.exec.sail, cmd)
  runner = runner or laravel.options.default_runner

  return runners[runner](cmd, opts), true
end

--- checks if sail is running, simple way of taking the ps response and if it empty just return false
---@return boolean
sail.is_running = function()
  local res = sail.run({ "ps" }, "sync")

  return #res.out > 1
end

return sail
