local events = require("laravel.events")
local nio    = require("nio")

---@class LaravelDumpServerProvider : laravel.providers.provider
local dump_server_provider = {}

function dump_server_provider:register(app)
  app:singletonIf("laravel.extensions.dump_server.lib")
  app:singletonIf("laravel.extensions.dump_server.ui")
  vim.tbl_map(function(command)
    app:addCommand("laravel.extensions.dump_server." .. command.signature, command)
  end, require("laravel.extensions.dump_server.commands"))
end

function dump_server_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.extensions.dump_server", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = events.DUMP_SERVER_RECORD_ADDED,
    callback = function()
      app("laravel.extensions.dump_server.ui"):update()
    end,
  })

  ---@type laravel.extensions.dump_server.lib
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
