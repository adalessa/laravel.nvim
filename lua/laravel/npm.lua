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
  local data, ok = laravel.run("npm", cmd, runner, { silent = opts.silent or false })

  if not ok then
    return {}, false
  end

  return data, true
end

return npm
