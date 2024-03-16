local create_user_command = require "laravel.user_commands.create_user_command"
local config = require "laravel.config"
local run = require "laravel.run"

local commands = {}

for command_name, group_commands in pairs(config.options.user_commands) do
  for name, details in pairs(group_commands) do
    commands[string.format("[%s] %s", command_name, name)] = function()
      run(command_name, details.cmd, details.opts)
    end
  end
end

return {
  setup = function()
    if not vim.tbl_isempty(commands) then
      create_user_command("LaravelMyCommands", nil, commands)
    end
  end,
}
