local app = require("laravel.core.app")

local commmand = {
  signature = "picker:make",
  description = "Open the make picker (artisan only make ones)",
}

function commmand:handle()
  ---@type laravel.managers.pickers_manager
  local pickers = app:make("pickers_manager")
  pickers:run("make")
end

return commmand
