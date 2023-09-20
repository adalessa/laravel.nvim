local config = require "laravel.config"
local environment = require "laravel.environment"
local runners = require "laravel.runners"

---@param name string
---@param args string[]
---@param opts table|nil
return function (name, args, opts)
  opts = opts or {}
  local executable = environment.get_executable(name)
  local cmd = vim.fn.extend(executable, args)

  local runner = opts.runner or config.options.commands_runner[args[1]] or config.options.default_runner

  return runners[runner](cmd, opts)
end
