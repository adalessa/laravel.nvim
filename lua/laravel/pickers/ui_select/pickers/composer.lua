local actions = require("laravel.pickers.common.actions")

---@class LaravelUISelectComposerPicker
---@field composer_repository ComposerRepository
local ui_artisan_picker = {}

function ui_artisan_picker:new(composer_repository)
  local instance = {
    composer_repository = composer_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function ui_artisan_picker:run(opts)
  opts = opts or {}

  return self.composer_repository:all():thenCall(function(commands)
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
  end, function(error)
    vim.api.nvim_err_writeln(error)
  end)
end

return ui_artisan_picker
