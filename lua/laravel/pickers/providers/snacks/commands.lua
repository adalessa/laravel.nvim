local format_entry = require("laravel.pickers.providers.snacks.format_entry")
local preview = require("laravel.pickers.providers.snacks.preview")

local commands_picker = {}

function commands_picker.run(opts, commands)
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
        Laravel.run(item.value.executable, item.value.cmd, item.value.opts)
      end
    end,
  }, opts or {}))
end

return commands_picker
