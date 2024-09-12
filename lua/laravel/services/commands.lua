---@class LaravelCommand

---@class LaravelCommandProvider
---@field api LaravelApi
local commands = {}

function commands:new(api)
  local instance = {
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param callback fun(commands: LaravelCommand[])
---@param error_callback fun(error: string)|nil
---@return vim.SystemObj
function commands:get(callback, error_callback)
  return self.api:async("artisan", { "list", "--format=json" }, function(result)
    if result:failed() then
      if error_callback then
        error_callback(result:prettyErrors())
      end
      return
    end
    callback(vim
      .iter(result:json().commands or {})
      :filter(function(command)
        return not command.hidden
      end)
      :totable())
  end, { wrap = true })
end

return commands
