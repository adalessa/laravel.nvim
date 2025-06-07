local app = require("laravel.core.app")

local command = {
  signature = "picker:commands",
  description = "Open the user defined commands picker",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("commands")
end

return command
