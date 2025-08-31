local actions = require("laravel.pickers.common.actions")

local composer_picker = {}

function composer_picker.run(opts, commands)
  vim.ui.select(
    commands,
    vim.tbl_extend("force", {
      prompt_title = "Composer commands",
      format_item = function(command)
        return command.name
      end,
      kind = "artisan",
    }, opts or {}),
    function(command)
      if command ~= nil then
        actions.composer_run(command)
      end
    end
  )
end

return composer_picker
