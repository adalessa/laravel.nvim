local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "picker:resoruces",
  description = "Open the resoruces picker",
  handle = nio.create(function()
    ---@type laravel.managers.pickers_manager
    local pickers = app:make("pickers_manager")
    pickers:run("resoruces")
  end, 1),
}
