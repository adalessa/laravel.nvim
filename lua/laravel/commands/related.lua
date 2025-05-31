local app = require("laravel.core.app")

local command = {
  signature = "picker:related",
  description = "Open the related picker of the current file",
}

function command:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("related")
end

return command
