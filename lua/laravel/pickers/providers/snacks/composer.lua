local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.providers.snacks.preview")
local format_entry = require("laravel.pickers.providers.snacks.format_entry")

local composer_picker = {}

function composer_picker.run(opts, commands)
  Snacks.picker.pick(vim.tbl_extend("force", {
    title = "Composer Commands",
    items = vim
      .iter(commands)
      :map(function(command)
        return {
          value = command,
          text = command.name,
        }
      end)
      :totable(),
    format = format_entry.composer_command,
    preview = preview.composer_command,
    confirm = function(picker, item)
      picker:close()
      if item then
        common_actions.composer_run(item.value)
      end
    end,
  }, opts or {}))
end

return composer_picker
