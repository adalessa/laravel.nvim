local actions = require("laravel.pickers.common.actions")
local Class = require("laravel.utils.class")
local nio = require("nio")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.ui.artisan
---@field artisan_loader laravel.loaders.artisan_cache_loader
local picker = Class({
  artisan_loader = "laravel.loaders.artisan_cache_loader",
})

function picker:run()
  nio.run(function()
    local commands, err = self.artisan_loader:load()
    if err then
      return notify.error("Error loading artisan commands: " .. err)
    end

    vim.schedule(function()
      vim.ui.select(commands, {
        prompt_title = "Artisan commands",
        format_item = function(command)
          return command.name
        end,
        kind = "artisan",
      }, function(command)
        if command ~= nil then
          actions.artisan_run(command)
        end
      end)
    end)
  end)
end

return picker
