local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:artisan",
  description = "Open the artisan picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("artisan")
  end, 1),
}
