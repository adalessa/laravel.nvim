local actions = require("laravel.ui_select.actions")

local commands_picker = {}

function commands_picker:new(runner, options)
  local instance = {
    runner = runner,
    options = options,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  opts = opts or {}

  local commands = {}

  for command_name, group_commands in pairs(self.options:get().user_commands) do
    for name, details in pairs(group_commands) do
      table.insert(commands, {
        executable = command_name,
        name = name,
        display = string.format("[%s] %s", command_name, name),
        cmd = details.cmd,
        desc = details.desc,
        opts = details.opts or {},
      })
    end
  end

  if vim.tbl_isempty(commands) then
    vim.notify("No user command defined in the config", vim.log.levels.WARN, {})
    return
  end

  vim.ui.select(commands, {
    prompt_title = "User Commands",
    format_item = function(command)
      return command.display
    end,
    kind = "resources",
  }, function(command)
    if command ~= nil then
      self.runner:run(command.executable, command.cmd, command.opts)
    end
  end)
end

return commands_picker
