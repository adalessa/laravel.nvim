local common_actions = require("laravel.pickers.common.actions")
local format_entry = require("laravel.pickers.providers.snacks.format_entry")
local preview = require("laravel.pickers.providers.snacks.preview")

local artisan_picker = {}

function artisan_picker.run(opts, commands)
  Snacks.picker.pick(vim.tbl_extend("force", {
    title = "Artisan Commands",
    items = vim
      .iter(commands)
      :map(function(command)
        return {
          value = command,
          text = command.name,
        }
      end)
      :totable(),
    format = format_entry.command,
    preview = preview.command,
    confirm = function(picker, item)
      picker:close()
      if item then
        common_actions.artisan_run(item.value)
      end
    end,
  }, opts or {}))
end

return artisan_picker
