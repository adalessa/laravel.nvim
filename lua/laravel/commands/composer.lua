local app = require("laravel.core.app")
local nio = require("nio")

local command = {
  signature = "picker:composer",
  description = "Open the composer picker",
}

command.handle = nio.create(function()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("composer")
end, 1)

return command
