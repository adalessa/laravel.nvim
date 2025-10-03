local nio = require("nio")

---@class LaravelDumpServerProvider : laravel.providers.provider
local dump_server_provider = {}

function dump_server_provider:register(app)
  app:singletonIf("laravel.extensions.dump_server.lib")
  app:singletonIf("laravel.extensions.dump_server.ui")
  vim.tbl_map(function(command)
    app:addCommand("laravel.extensions.dump_server." .. command.signature, command)
  end, require("laravel.extensions.dump_server.commands"))

  app:bind("laravel.extensions.dump_server.ui_update_listener", function()
    return {
      event = require("laravel.extensions.dump_server.record_added_event"),
      hanle = function()
        app("laravel.extensions.dump_server.ui"):update()
      end,
    }
  end, { tags = { "listener" } })
end

function dump_server_provider:boot(app, opts)
  ---@type laravel.extensions.dump_server.lib
  app("laravel.extensions.dump_server.ui"):setConfig(opts)

  local lib = app:make("laravel.extensions.dump_server.lib")
  Laravel.extensions.dump_server = {
    start = nio.create(function()
      return lib:start()
    end),
    stop = function()
      return lib:stop()
    end,
    isRunning = function()
      return lib:isRunning()
    end,
    records = function()
      return lib.records
    end,
    unseenRecords = function()
      return lib:unseenRecords()
    end,
  }
end

return dump_server_provider
