local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.commands
---@field runner laravel.services.runner
---@field commands_loader laravel.loaders.user_commands_loader
local commands_picker = Class({
  runner = "laravel.services.runner",
  commands_loader = "laravel.loaders.user_commands_loader",
})

---@async
function commands_picker:run(picker, opts)
  local commands = self.commands_loader:load()
  if #commands == 0 then
    notify.error("No user commands found")
    return
  end

  vim.schedule(function()
    picker.run(opts, commands)
  end)
end

return commands_picker
