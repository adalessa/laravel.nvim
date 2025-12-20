local notify = require("laravel.utils.notify")
local app = require("laravel.core.app")

local command = {
  signature = "dev:start",
  description = "Start Developer Server with composer run dev",
}

function command:handle()
  local lib = app:make("laravel.extensions.composer_dev.lib")

  if lib:isRunning() then
    notify.info("Server already running")
    return
  end

  local err = lib:start()
  if not err then
    notify.info("Server started at " .. lib:hostname())
  else
    notify.error("Failed to start server: " .. err:toString())
  end
end

return command
