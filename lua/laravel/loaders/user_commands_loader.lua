local Class = require("laravel.utils.class")

---@class laravel.loaders.user_commands_loader
---@field options laravel.core.options_manager
local user_commands_loader = Class({
  options = "laravel.core.options_manager",
})

---@return laravel.dto.user_command[]
function user_commands_loader:load()
  local commands = {}

  for command_name, group_commands in pairs(self.options.get("user_commands", {})) do
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
