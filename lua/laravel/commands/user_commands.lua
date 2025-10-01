local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:commands",
  description = "Open the user defined commands picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("commands")
  end, 1),
}
