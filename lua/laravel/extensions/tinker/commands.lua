local app = require("laravel.core.app")

return {
  {
    signature = "tinker:open",
    description = "Open Tinker",
    handle = function()
      ---@type laravel.extensions.tinker.lib
      local lib = app:make("laravel.extensions.tinker.lib")
      lib:open()
    end,
  },
  {
    signature = "tinker:create",
    description = "Create a new Tinker File",
    handle = function()
      ---@type laravel.extensions.tinker.lib
      local lib = app:make("laravel.extensions.tinker.lib")
      lib:create()
    end,
  },
  {
    signature = "tinker:select",
    description = "Open the selector for existing tinker files",
    handle = function()
      ---@type laravel.extensions.tinker.lib
      local lib = app:make("laravel.extensions.tinker.lib")
      lib:select()
    end,
  },
}
