local container = require "laravel._container"
local environment = require "laravel.environment"
local utils = require "laravel.utils"
local runners = require "laravel.runners"

local app = nil

---@param options laravel.config
local initialize = function(options)
  app = nil

  if vim.fn.filereadable "artisan" == 0 then
    return
  end

  local resolvedEnv = environment.initialize(options.environment.environments, options.environment.resolver)
  -- fill with the environment
  if not resolvedEnv then
    utils.notify("App", { msg = "Could not initialize environment", level = "ERROR" })
    return
  end

  app = {
    envSetup = resolvedEnv,
    environment = resolvedEnv(),
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
  app.environment = app.envSetup()
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
  local is_tinker = command == "artisan" and args[1] == "tinker"

  local cmd = build_command(command, args)
  local runner = opts.runner or app.options.commands_runner[args[1]] or app.options.default_runner

  local result, ok = runners[runner](cmd, opts), true

  if ok and is_tinker and runner == "terminal" then
    container.set("tinker", result.term_id)
    vim.api.nvim_create_autocmd({ "BufDelete" }, {
      buffer = result.buff,
      callback = function()
        container.unset "tinker"
      end,
    })
  end

  return result, ok
end

---@param decorated function
local check_ready = function(decorated)
  return function(...)
    if not ready() then
      utils.notify(
        "application",
        { level = "ERROR", msg = "The application is not ready for current working directory" }
      )
    end

    return decorated(...)
  end
end

return {
  initialize = initialize,

  run = check_ready(run),

  has_command = check_ready(has_command),

  warmup = check_ready(warmup),

  ready = ready,

  container = container,

  get_options = check_ready(function()
    return app.options
  end),

  get_info = function()
    local info = {
      ready = ready(),
    }

    if not ready() then
      return info
    end

    info.options = app.options
    info.environment = app.environment

    return info
  end,
}
