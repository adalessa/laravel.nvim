local app = require("laravel.core.app")
local nio = require("nio")

return {
  {
    signature = "dump_server:start",
    description = "Start Dump Server",
    handle = function()
      ---@type laravel.extensions.dump_server.lib
      local lib = app:make("laravel.extensions.dump_server.lib")
      nio.run(function()
        lib:start()
      end)
    end,
  },
  {
    signature = "dump_server:stop",
    description = "Stop Dump Server",
    handle = function()
      ---@type laravel.extensions.dump_server.lib
      local lib = app:make("laravel.extensions.dump_server.lib")
      lib:stop()
    end,
  },
  {
    signature = "dump_server:open",
    description = "Open Dump Server UI",
    handle = function()
      ---@type laravel.extensions.dump_server.ui
      local ui = app:make("laravel.extensions.dump_server.ui")
      nio.run(function()
        ui:open()
      end)
    end,
  },
  {
    signature = "dump_server:close",
    description = "Close Dump Server UI",
    handle = function()
      ---@type laravel.extensions.dump_server.ui
      local ui = app:make("laravel.extensions.dump_server.ui")
      ui:close()
    end,
  },
  {
    signature = "dump_server:toggle",
    description = "Toggle Dump Server UI",
    handle = function()
      ---@type laravel.extensions.dump_server.ui
      local ui = app:make("laravel.extensions.dump_server.ui")
      nio.run(function()
        ui:toggle()
      end)
    end,
  },
  {
    signature = "dump_server:install",
    description = "Install Dump Server",
    handle = function()
      ---@type laravel.extensions.dump_server.lib
      local lib = app:make("laravel.extensions.dump_server.lib")
      nio.run(function()
        lib:install()
      end)
    end,
  },
}
