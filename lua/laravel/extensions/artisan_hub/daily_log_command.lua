local LogPtyCommand = require("laravel.extensions.artisan_hub.log_pty_command")

local AppDailyLogCommand = setmetatable({}, { __index = LogPtyCommand })
AppDailyLogCommand.__index = AppDailyLogCommand

function AppDailyLogCommand:new()
  local instance = {
    cmd = "tail -f -n 0 storage/logs/" .. os.date("laravel-%Y-%m-%d.log"),
    name = "Application Logs",
    job_id = nil,
    bufnr = nil,
    exited = false,
  }

  setmetatable(instance, self)
  return instance
end

return AppDailyLogCommand

