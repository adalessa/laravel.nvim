local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:routes",
  description = "Open the routes picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("routes")
  end, 1),
}
