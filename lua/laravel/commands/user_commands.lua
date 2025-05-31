local app = require("laravel.core.app")

local command = {
  signature = "picker:commands",
  description = "Open the user defined commands picker",
}

function command:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("commands")
end

return command
