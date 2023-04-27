local runners = require "laravel.runners"

local container = {}

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table|nil
---@return table, boolean
container.run = function(cmd, runner, opts)
  opts = opts or {}
  local laravel = require("laravel").app
  return laravel.run("container", cmd, runner, opts)
end

return container
