local actions = require("laravel.pickers.common.actions")
local is_make_command = require("laravel.utils.init").is_make_command
local Class = require("laravel.utils.class")
local nio = require("nio")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.ui.make
---@field artisan_loader laravel.loaders.artisan_cache_loader
local make_picker = Class({
  artisan_loader = "laravel.loaders.artisan_cache_loader",
})

function make_picker:run()
  nio.run(function()
    local commands, err = self.artisan_loader:load()
    if err then
      return notify.error("Error loading make commands: " .. err)
    end

    vim.schedule(function()
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
          if command ~= nil then
            actions.make_run(command)
          end
        end
      )
    end)
  end)
end

return make_picker
