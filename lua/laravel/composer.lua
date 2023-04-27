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
  local data, ok = laravel.run("composer", cmd, runner, opts)

  if not ok then
    return {}, false
  end

  return data, true
end

return composer
