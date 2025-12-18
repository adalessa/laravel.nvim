local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:resources",
  description = "Open the resources picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("resources")
  end, 1),
}
