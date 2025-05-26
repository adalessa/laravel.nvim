local Class = require("laravel.utils.class")

---@class laravel.dto.user_command
---@field executable string
---@field name string
---@field display string
---@field cmd string
---@field desc string
---@field opts table<string, any>

---@class laravel.loaders.user_commands_loader
---@field config laravel.services.config
---@field new fun(self: laravel.loaders.user_commands_loader, config: laravel.services.config): laravel.loaders.user_commands_loader
local user_commands_loader = Class({
  config = "laravel.services.config",
})

---@return laravel.dto.user_command[]
function user_commands_loader:load()
  local commands = {}

  for command_name, group_commands in pairs(self.config.get("user_commands", {})) do
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

  return commands
end

return user_commands_loader
