local app = require("laravel.core.app")

local commmand = {
  signature = "picker:make",
  description = "Open the make picker (artisan only make ones)",
}

function commmand:handle()
  ---@type laravel.pickers.pickers_manager
  local pickers = app:make("pickers")
  pickers:run("make")
end

return commmand
