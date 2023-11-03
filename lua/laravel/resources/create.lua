local is_resource = require "laravel.resources.is_resource"
local open = require "laravel.resources.open"
local notify = require "laravel.notify"
local api = require "laravel.api"

return function(command)
  local resource = command[1]
  local name = command[2]

  if not is_resource(resource) then
    notify(
      "Resource.Create",
      { level = "ERROR", msg = string.format("Command %s is not a resource creation suported", resource) }
    )

    return false
  end

  api.async("artisan", command, function()
    open(resource, name)
  end)

  return true
end
