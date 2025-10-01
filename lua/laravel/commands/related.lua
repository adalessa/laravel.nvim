local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:related",
  description = "Open the related picker of the current file",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("related")
  end, 1),
}
