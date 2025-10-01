local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:make",
  description = "Open the make picker (artisan only make ones)",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("make")
  end, 1),
}
