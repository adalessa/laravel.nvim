local actions = require("laravel.pickers.common.actions")
local is_make_command = require("laravel.utils").is_make_command

---@class LaravelUISelectMakePicker
---@field commands_repository CommandsRepository
local make_picker = {}

function make_picker:new(cache_commands_repository)
  local instance = {
    commands_repository = cache_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make_picker:run(opts)
  opts = opts or {}

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
