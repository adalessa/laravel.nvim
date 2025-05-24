local promise = require("promise")
local Class = require("laravel.class")

---@class laravel.dto.user_command
---@field executable string
---@field name string
---@field display string
---@field cmd string
---@field desc string
---@field opts table<string, any>

---@class laravel.loaders.user_commands_loader
---@field options laravel.services.options
local user_commands_loader = Class({
  options = "laravel.services.options",
})

---@return Promise<laravel.dto.user_command[]>
function user_commands_loader:load()
  return promise.resolve(vim
    .iter(self.options:get("user_commands", {}))
    :map(function(command, definitons)
      return vim.iter(definitons):map(function(name, details)
        return {
          executable = command,
          name = name,
          display = string.format("[%s] %s", command, name),
          cmd = details.cmd,
          desc = details.desc,
          opts = details.opts or {},
        }
      end)
    end)
    :totable())
end

return user_commands_loader
