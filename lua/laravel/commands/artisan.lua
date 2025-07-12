local app = require("laravel.core.app")
local nio = require("nio")

local command = {
  signature = "picker:artisan",
  description = "Open the artisan picker",
}

command.handle = nio.create(function()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("artisan")
end, 1)

return command
