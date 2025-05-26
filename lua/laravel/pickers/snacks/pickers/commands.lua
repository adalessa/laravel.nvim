local Class = require("laravel.utils.class")
local nio = require("nio")

local format_entry = require("laravel.pickers.snacks.format_entry")
local preview = require("laravel.pickers.snacks.preview")

---@class laravel.pickers.snacks.commands
---@field runner laravel.services.runner
---@field commands_loader laravel.loaders.user_commands_loader
local commands_picker = Class({
  runner = "laravel.services.runner",
  commands_loader = "laravel.loaders.user_commands_loader",
})

function commands_picker:run(opts)
  nio.run(function()
    local commands = self.commands_loader:load()

    vim.schedule(function()
      Snacks.picker.pick(vim.tbl_extend("force", {
        title = "User Commands",
        items = vim
          .iter(commands)
          :map(function(command)
            return {
              value = command,
              text = command.display,
            }
          end)
          :totable(),
        format = format_entry.user_command,
        preview = preview.user_command,
        confirm = function(picker, item)
          picker:close()
          if item then
            self.runner:run(item.value.executable, item.value.cmd, item.value.opts)
          end
        end,
      }, opts or {}))
    end)
  end)
end

return commands_picker
