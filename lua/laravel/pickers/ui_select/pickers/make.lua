local actions = require("laravel.pickers.common.actions")
local is_make_command = require("laravel.utils").is_make_command
local Class = require("laravel.class")

---@class laravel.pickers.ui.make
---@field commands_repository laravel.repositories.artisan_commands
local make_picker = Class({
  commands_repository = "laravel.repositories.cache_commands_repository",
})

function make_picker:run()
  self.commands_repository:all():thenCall(function(commands)
    vim.ui.select(
      vim
        .iter(commands)
        :filter(function(command)
          return is_make_command(command.name)
        end)
        :totable(),
      {
        prompt = "Make commands",
        format_item = function(command)
          return command.name
        end,
        kind = "make",
      },
      function(command)
        if command == nil then
          actions.make_run(command)
        end
      end
    )
  end)
end

return make_picker
