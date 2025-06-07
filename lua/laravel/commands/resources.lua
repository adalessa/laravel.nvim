local app = require("laravel.core.app")

local command = {
  signature = "picker:resoruces",
  description = "Open the resoruces picker",
}

function command:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("resoruces")
end

return command
