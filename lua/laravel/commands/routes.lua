local app = require("laravel.core.app")

local command = {
  signature = "picker:routes",
  description = "Open the routes picker",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("routes")
end

return command
