local nio = require("nio")
local Class = require("laravel.class")
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")

---@class laravel.pickers.snacks.artisan
---@field commands_loader laravel.loaders.artisan_cache_loader
local artisan_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
})

function artisan_picker:run(opts)
  nio.run(function()
    local commands, err = self.commands_loader:load()
    if err then
      vim.notify("Failed to load artisan commands: " .. err, vim.log.levels.ERROR)
      return
    end

    vim.schedule(function()
      Snacks.picker.pick(vim.tbl_extend("force", {
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
  end)
end

return artisan_picker
