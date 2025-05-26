---@class laravel.repositories.artisan_commands
---@field api laravel.services.api
local commands_repository = {}

function commands_repository:new(api)
  local instance = { api = api }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function commands_repository:all()
  return self.api:send("artisan", { "list", "--format=json" }):thenCall(
    ---@param result laravel.dto.apiResponse
    function(result)
      return vim
          .iter(result:json().commands or {})
          :filter(function(command)
            return not command.hidden
          end)
          :totable()
    end
  )
end

return commands_repository
