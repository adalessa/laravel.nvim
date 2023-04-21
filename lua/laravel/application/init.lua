local container = require "laravel._container"
local environment = require "laravel.environment"
local utils = require "laravel.utils"
local runners = require "laravel.runners"

local app = nil

---@param options laravel.config
local initialize = function(options)
  if app ~= nil then
    utils.notify("Application Initialize", { msg = "App already initialize", level = "ERROR" })
    return
  end

  local env = environment.initialize(options.environment.environments, options.environment.resolver)
  -- fill with the environment
  if not env then
    utils.notify("App", { msg = "Could not initialize environment", level = "ERROR" })
    return
  end

  app = {
    environment = env,
    options = options,
  }
end

---@param command string
---@return boolean
local has_command = function(command)
  local executable = app.environment.executables[command]

  return executable ~= nil
end

---@param command string
---@param args table
local build_command = function(command, args)
  local out = {}
  if not has_command(command) then
    utils.notify("Build command", {
      msg = string.format("Command %s not available in environment", command),
      level = "ERROR",
    })

    return
  end

  local executable = app.environment.executables[command]

  for _, part in ipairs(executable) do
    table.insert(out, part)
  end

  for _, part in ipairs(args) do
    table.insert(out, part)
  end
  return out
end

local warmup = function()
  require("laravel.commands").load()
  require("laravel.routes").load()
end

---@return boolean
local ready = function()
  return app ~= nil
end

---@param command string
---@param args table
---@param opts table
---@return table, boolean
local run = function(command, args, opts)
  opts = opts or {}
  local cmd = build_command(command, args)
  local runner = opts.runner or app.options.commands_runner[cmd[1]] or app.options.default_runner

  return runners[runner](cmd, opts), true
end

return {
  initialize = initialize,

  run = run,

  has_command = has_command,

  warmup = warmup,

  ready = ready,

  container = container,

  get_options = function()
    return app.options
  end,
}
