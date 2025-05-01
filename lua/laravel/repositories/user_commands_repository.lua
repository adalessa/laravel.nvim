local promise = require("promise")

---@class UserCommandsRepository
---@field options LaravelOptionsService
local user_commands_repository = {}

function user_commands_repository:new(options)
  local instance = { options = options }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function user_commands_repository:all()
  local commands = {}

  for command_name, group_commands in pairs(self.options:get("user_commands")) do
    for name, details in pairs(group_commands) do
      table.insert(commands, {
        executable = command_name,
        name = name,
        display = string.format("[%s] %s", command_name, name),
        cmd = details.cmd,
        desc = details.desc,
        opts = details.opts or {},
      })
    end
  end

  return promise:new(function(resolve, reject)
    if vim.tbl_isempty(commands) then
      reject("No user command defined in the config")
      return
    end

    resolve(commands)
  end)
end

return user_commands_repository
