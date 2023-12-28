local is_resource = require "laravel.resources.is_resource"
local open = require "laravel.resources.open"
local api = require "laravel.api"

return function(command)
  local resource = command[1]
  local name = command[2]

  if not is_resource(resource) then
    vim.notify(string.format("Command %s is not a resource creation suported", resource), vim.log.levels.ERROR)

    return
  end

  api.async(
    "artisan",
    command,
    ---@param response ApiResponse
    function(response)
      if response:failed() then
        vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
      else
        open(resource, name)
      end
    end
  )
end
