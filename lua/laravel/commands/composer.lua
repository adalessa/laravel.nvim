local app = require("laravel.core.app")

local command = {
  signature = "picker:composer",
  description = "Open the composer picker",
}

function command:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("composer")
end

return command
