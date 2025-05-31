local app = require("laravel.core.app")

local command = {
  signature = "picker:resoruces",
  description = "Open the resoruces picker",
}

function command:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("resoruces")
end

return command
