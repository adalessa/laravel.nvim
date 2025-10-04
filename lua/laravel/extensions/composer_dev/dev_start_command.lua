local notify = require("laravel.utils.notify")
local nio = require("nio")
local app = require("laravel.core.app")

local command = {
  signature = "dev:start",
  description = "Start Developer Server",
}

function command:handle()
  local lib = app:make("laravel.extensions.composer_dev.lib")

  if lib:isRunning() then
    notify.info("Server already running")
    return
  end

  nio.run(function()
    local err = lib:start()
    vim.schedule(function()
      if not err then
        notify.info("Server started at " .. lib:hostname())
      else
        notify.error("Failed to start server: " .. err:toString())
      end
    end)
  end)
end

return command
