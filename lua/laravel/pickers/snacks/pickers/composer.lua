local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local composer_picker = Class({
  composer_loader = "laravel.loaders.composer_commands_cache_loader",
  log = "laravel.utils.log",
})

function composer_picker:run(opts)
  local commands, err = self.composer_loader:load()
  if err then
    notify.error("Failed to load composer commands")
    self.log:error(err)
    return
  end

  vim.schedule(function()
    Snacks.picker.pick(vim.tbl_extend("force", {
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
