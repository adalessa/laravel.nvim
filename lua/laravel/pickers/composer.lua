local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.composer
---@field composer_loader laravel.loaders.user_commands_loader
---@field log laravel.utils.log
local composer_picker = Class({
  composer_loader = "laravel.loaders.composer_commands_cache_loader",
  log = "laravel.utils.log",
})

---@async
function composer_picker:run(picker, opts)
  local commands, err = self.composer_loader:load()
  if err then
    notify.error("Failed to load composer commands")
    self.log:error(err)
    return
  end

  vim.schedule(function()
    picker.run(opts, commands)
  end)
end

return composer_picker
