local app = require("laravel.core.app")

local command = {
  signature = "picker:related",
  description = "Open the related picker of the current file",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("related")
end

return command
