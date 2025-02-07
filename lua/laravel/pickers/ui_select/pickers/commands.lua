local commands_picker = {}

function commands_picker:new(runner, user_commands_repository)
  local instance = {
    runner = runner,
    user_commands_repository = user_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  self.user_commands_repository:all():thenCall(function(commands)
    vim.ui.select(
      commands,
      vim.tbl_extend("force", {
        prompt_title = "User Commands",
        format_item = function(command)
          return command.display
        end,
        kind = "resources",
      }, opts or {}),
      function(command)
        if command ~= nil then
          self.runner:run(command.executable, command.cmd, command.opts)
        end
      end
    )
  end)
end

return commands_picker
