local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:composer",
  description = "Open the composer picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("composer")
  end, 1),
}
