local LogPtyCommand = require("laravel.extensions.artisan_hub.log_pty_command")

local AppLogCommand = setmetatable({}, { __index = LogPtyCommand })
AppLogCommand.__index = AppLogCommand

function AppLogCommand:new()
  local instance = {
    cmd = "tail -f -n 0 storage/logs/laravel.log",
    name = "Application Logs",
    job_id = nil,
    bufnr = nil,
    exited = false,
  }

  setmetatable(instance, self)
  return instance
end

return AppLogCommand
