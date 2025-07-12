local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.artisan
---@field commands_loader laravel.loaders.artisan_cache_loader
---@field log laravel.utils.log
local artisan_picker = Class({
  commands_loader = "laravel.loaders.artisan_cache_loader",
  log = "laravel.utils.log",
})

---@async
function artisan_picker:run(picker, opts)
  local commands, err = self.commands_loader:load()
  if err then
    notify.error("Failed to load artisan commands")
    self.log:error(err)
    return
  end

  vim.schedule(function()
    picker.run(opts, commands)
  end)
end

return artisan_picker
