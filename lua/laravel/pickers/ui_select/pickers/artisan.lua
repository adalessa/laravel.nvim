local actions = require("laravel.pickers.ui_select.actions")

---@class LaravelUISelectArtisanPicker
---@field commands_repository CommandsRepository
local ui_artisan_picker = {}

function ui_artisan_picker:new(cache_commands_repository)
  local instance = {
    commands_repository = cache_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui_artisan_picker:run(opts)
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
        actions.run(command)
      end
    end)
  end, function(error)
    vim.api.nvim_err_writeln(error)
  end)
end

return ui_artisan_picker
