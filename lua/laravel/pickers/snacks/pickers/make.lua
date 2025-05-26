local snacks = require("snacks").picker
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")
local is_make_command = require("laravel.utils.init").is_make_command

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
  return self.commands_repository:all():thenCall(function(commands)
    snacks.pick(vim.tbl_extend("force", {
      title = "Artisan Commands",
      items = vim
        .iter(commands)
        :filter(function(command)
          return is_make_command(command.name)
        end)
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
          common_actions.make_run(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return make_picker
