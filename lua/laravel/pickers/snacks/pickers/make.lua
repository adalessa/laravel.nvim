local snacks = require("snacks").picker
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")
local is_make_command = require("laravel.utils.init").is_make_command
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.snacks.make
---@field commands_loader laravel.loaders.artisan_cache_loader
local make_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
})

function make_picker:run(opts)
  local commands, err = self.commands_loader:load()
  if err then
    notify.error("Failed to load artisan commands: " .. err)
    return
  end

  vim.schedule(function()
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
