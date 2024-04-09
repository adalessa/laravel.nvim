local api = require "laravel.api"


---@class Command
---@field name string
---@field hidden boolean
---@field help string
---@field description string
---@field usage string[]
---@field definition CommandDefinition

---@class CommandDefinition
---@field arguments table<string, CommandArgument>
---@field options table<string, CommandOption>

---@class CommandArgument
---@field name string
---@field description string
---@field is_required boolean

---@class CommandOption
---@field description string
---@field is_multiple boolean
---@field name string
---@field shortcut string

local commands_resolver = {};

local function parse(json)
  local res = vim.json.decode(json, {
    luanil = { object = true, array = true }
  })

  if not res then
    return nil
  end

  return res.commands
end


---@param onSuccess fun(commands: table)|nil
---@param onFailure fun(errorMessage: string)|nil
function commands_resolver.resolve(
  onSuccess,
  onFailure
)
  api.async("artisan", { "list", "--format=json" }, function(result)
    if result:failed() then
      if onFailure then onFailure(result:prettyErrors()) end
      return
    end

    ---@type Command[]|nil
    local commands = parse(result:prettyContent())

    if not commands then
      if onFailure then onFailure("no artisan commands found") end
      return
    end

    if onSuccess then onSuccess(commands) end
  end)
end

return commands_resolver
