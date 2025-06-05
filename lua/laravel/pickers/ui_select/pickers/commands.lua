local Class = require("laravel.utils.class")

---@class laravel.pickers.ui_select.commands
---@field runner laravel.services.runner
---@field commands_loader laravel.loaders.user_commands_loader
local commands_picker = Class({
  runner = "laravel.services.runner",
  commands_loader = "laravel.loaders.user_commands_loader",
})

function commands_picker:run(opts)
  local commands = self.commands_loader:load()
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
end

return commands_picker
