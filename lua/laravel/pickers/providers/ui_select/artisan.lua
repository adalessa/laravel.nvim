local actions = require("laravel.pickers.common.actions")

local artisan_picker = {}

function artisan_picker.run(opts, commands)
  vim.ui.select(
    commands,
    vim.tbl_extend("force", {
      prompt_title = "Artisan commands",
      format_item = function(command)
        return command.name
      end,
      kind = "artisan",
    }, opts or {}),
    function(command)
      if command ~= nil then
        actions.artisan_run(command)
      end
    end
  )
end

return artisan_picker
