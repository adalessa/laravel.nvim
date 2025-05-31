local app = require("laravel.core.app")
local notify = require("laravel.utils.notify")

local command = {
  signature = "dev:stop",
  description = "Stop Developer Server",
}

function command:handle()
  ---@type laravel.extensions.composer_dev.lib
  local lib = app:make("laravel.extensions.composer_dev.lib")
  lib:stop()
  notify.info("Server stopped")
end

return command
