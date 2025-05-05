---@class ComposerRepository
---@field api laravel.api
local composer_repository = {}

function composer_repository:new(api)
  local instance = { api = api }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function composer_repository:all()
  return self.api:send("composer", { "list", "--format=json" }):thenCall(
    ---@param result laravel.dto.apiResponse
    function(result)
      return vim.iter(result:json().commands or {}):filter(function(command)
        return not command.hidden
      end):totable()
    end
  )
end

return composer_repository
