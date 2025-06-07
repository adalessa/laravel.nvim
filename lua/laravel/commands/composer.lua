local app = require("laravel.core.app")

local command = {
  signature = "picker:composer",
  description = "Open the composer picker",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("composer")
end

return command
