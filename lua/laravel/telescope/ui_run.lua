local application_run = require "laravel.run"
local is_resource = require "laravel.resources.is_resource"
local create = require "laravel.resources.create"
local config = require "laravel.config"

return function(command, ask_options)
  local command_options = config.options.commands_options[command.name] or {}
  local function build_prompt(argument)
    local prompt = "Argument " .. argument.name .. " "
    if argument.is_required then
      prompt = prompt .. "<require>"
    else
      prompt = prompt .. "<optional>"
    end

    return prompt .. ":"
  end

  local function get_arguments(args, callback, values)
    if #args == 0 then
      callback(values)
      return
    end

    vim.ui.input({ prompt = build_prompt(args[1]) }, function(value)
      if value == "" and args[1].is_required then
        return
      end
      table.insert(values, value)
      table.remove(args, 1)
      get_arguments(args, callback, values)
    end)
  end

  local function run(args, options)
    local cmd = { command.name }
    for _, arg in pairs(args) do
      table.insert(cmd, arg)
    end

    if options ~= nil and options ~= "" then
      for _, value in pairs(vim.fn.split(options, " ")) do
        table.insert(cmd, value)
      end
    end

    if is_resource(cmd[1]) then
      return create(cmd)
    end

    application_run("artisan", cmd, {})
  end

  local args = {}
  for _, argument in pairs(command.definition.arguments) do
    table.insert(args, argument)
  end

  if command_options.skip_args then
    if ask_options then
      vim.ui.input({ prompt = "Options" }, function(options)
        run({}, options)
      end)
      return
    end
    run({}, nil)
    return
  end

  get_arguments(args, function(values)
    if ask_options then
      vim.ui.input({ prompt = "Options" }, function(options)
        run(values, options)
      end)
      return
    end
    run(values, nil)
  end, {})

  return true
end
