local snacks = require("snacks").picker
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")

local composer_picker = {}

function composer_picker:new(composer_repository)
  local instance = {
    composer_repository = composer_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function composer_picker:run(opts)
  return self.composer_repository:all():thenCall(function(commands)
    snacks.pick(vim.tbl_extend("force", {
      title = "Composer Commands",
      items = vim
        .iter(commands)
        :map(function(command)
          return {
            value = command,
            text = command.name,
          }
        end)
        :totable(),
      format = format_entry.composer_command,
      preview = preview.composer_command,
      confirm = function(picker, item)
        picker:close()
        if item then
          common_actions.composer_run(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return composer_picker
