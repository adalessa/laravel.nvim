local application = require "laravel.application"

---@class CommandArgument
---@field name string
---@field is_required boolean
---@field is_array boolean
---@field description string
---@field default string

---@class CommandOption
---@field name string
---@field shortcut string|nil
---@field accept_value boolean
---@field is_value_required boolean
---@field is_multiple boolean
---@field description string
---@field default any

---@class CommandDefinition
---@field arguments CommandArgument[]
---@field options CommandOption[]

---@class LaravelCommand
---@field name string
---@field description string
---@field usage string[]
---@field help string
---@field hidden boolean
---@field definition CommandDefinition
---@field runner string

local M = {}

---Gets list of commands from the raw json
---@param json string
---@return LaravelCommand[]
M.from_json = function(json)
  local cmds = {}

  if json == "" or json == nil or #json == 0 then
    return cmds
  end

  for _, cmd in ipairs(vim.fn.json_decode(json).commands) do
    if not cmd.hidden then
      table.insert(cmds, cmd)
    end
  end
  return cmds
end

--- Gets the runner for a given command
---@param command LaravelCommand
M.get_runner = function(command)
  local runner = application.get_options().commands_runner[command.name]
  if runner ~= nil then
    return runner
  end

  return application.get_options().default_runner
end

return M
