local app = require("laravel.core.app")

local command = {
  signature = "picker:artisan",
  description = "Open the artisan picker",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("artisan")
end

return command
