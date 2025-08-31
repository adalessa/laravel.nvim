local commands_picker = {}

function commands_picker.run(opts, commands)
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
        Laravel.run(command.executable, command.cmd, command.opts)
      end
    end
  )
end

return commands_picker
