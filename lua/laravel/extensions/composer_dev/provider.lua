local nio = require("nio")
---@type laravel.extensions.provider
local composer_dev = {}

function composer_dev.register(app)
  app:singleton("laravel.extensions.composer_dev.lib")
  app:addCommand("laravel.extensions.composer_dev.dev_start_command")
  app:addCommand("laravel.extensions.composer_dev.dev_stop_command")
end

function composer_dev.boot(app)
  ---@type laravel.extensions.composer_dev.lib
  local lib = app:make("laravel.extensions.composer_dev.lib")
  Laravel.extensions.composer_dev = {
    start = nio.create(function()
      return lib:start()
    end, 0),
    stop = function()
      return lib:stop()
    end,
    isRunning = function()
      return lib:isRunning()
    end,
    ---@return string
    hostname = function()
      return lib:hostname()
    end,
  }
end

return composer_dev
