local actions = require("laravel.pickers.common.actions")
local Class = require("laravel.class")

---@class laravel.pickers.ui.artisan
---@field commands_repository laravel.repositories.artisan_commands
local picker = Class({
  commands_repository = "laravel.repositories.cache_commands_repository",
})

function picker:run(opts)
  opts = opts or {}

  return self.commands_repository:all():thenCall(function(commands)
    vim.ui.select(commands, {
      prompt_title = "Artisan commands",
      format_item = function(command)
        return command.name
      end,
      kind = "artisan",
    }, function(command)
      if command ~= nil then
          actions.artisan_run(command)
      end
    end)
  end, function(error)
    error(error)
  end)
end

return picker
