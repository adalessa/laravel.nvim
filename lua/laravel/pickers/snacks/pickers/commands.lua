local snacks = require("snacks").picker
local format_entry = require("laravel.pickers.snacks.format_entry")
local preview = require("laravel.pickers.snacks.preview")

local commands_picker = {}

function commands_picker:new(runner, user_commands_repository)
  local instance = {
    runner = runner,
    user_commands_repository = user_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  self.user_commands_repository:all():thenCall(function(commands)
    snacks.pick(vim.tbl_extend("force", {
      title = "User Commands",
      items = vim
        .iter(commands)
        :map(function(command)
          return {
            value = command,
            text = command.display,
          }
        end)
        :totable(),
      format = format_entry.user_command,
      preview = preview.user_command,
      confirm = function(picker, item)
        picker:close()
        if item then
          self.runner:run(item.value.executable, item.value.cmd, item.value.opts)
        end
      end,
    }, opts or {}))
  end)
end

return commands_picker
