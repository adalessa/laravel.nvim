local actions = require("laravel.pickers.common.actions")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")

local composer_picker = Class({
  composer_loader = "laravel.loaders.composer_commands_cache_loader",
})

function composer_picker:run()
  local commands, err = self.composer_loader:load()
  if err then
    return notify.error("Failed to load composer commands: " .. err)
  end

  vim.schedule(function()
    vim.ui.select(commands, {
      prompt_title = "Composer commands",
      format_item = function(command)
        return command.name
      end,
      kind = "artisan",
    }, function(command)
      if command ~= nil then
        actions.composer_run(command)
      end
    end)
  end)
end

return composer_picker
