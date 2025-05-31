local app = require("laravel.core.app")

local command = {
  signature = "picker:routes",
  description = "Open the routes picker",
}

function command:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("routes")
end

return command
