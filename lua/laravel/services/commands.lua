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
---@return Job
function commands:get(callback)
  return self.api:async("artisan", { "list", "--format=json" }, function(result)
    if result:failed() then
      vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
      return
    end
    callback(vim
      .iter(result:json().commands or {})
      :filter(function(command)
        return not command.hidden
      end)
      :totable())
  end)
end

return commands
