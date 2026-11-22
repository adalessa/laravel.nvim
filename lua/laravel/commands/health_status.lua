local health = require("laravel.core.health")
local notify = require("laravel.utils.notify")

return {
  signature = "health:status",
  description = "Show the health of the Laravel environment",
  handle = function()
    local status = health.getStatus()
    local message = "Laravel environment: " .. status
    local err = health.getError()

    if err then
      message = message .. "\n" .. err
    end

    if status == "unavailable" then
      notify.warn(message)
    elseif status == "broken" then
      notify.error(message)
    else
      notify.info(message)
    end
  end,
}
