local snacks = require("snacks").picker
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")

---@class LaravelPickersSnacksArtisan
---@field commands_repository laravel.repositories.artisan_commands
local artisan_picker = {}

function artisan_picker:new(cache_commands_repository)
  local instance = {
    commands_repository = cache_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function artisan_picker:run(opts)
  return self.commands_repository:all():thenCall(function(commands)
    snacks.pick(vim.tbl_extend("force", {
      title = "Artisan Commands",
      items = vim
        .iter(commands)
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
          common_actions.artisan_run(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return artisan_picker
