local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.dto.composer_command
---@field name string

---@class laravel.loaders.composer_commands_loader
---@field api laravel.services.api
local ComposerCommandsLoader = Class({ api = "laravel.services.api" })

---@async
---@return laravel.dto.composer_command[], laravel.error
function ComposerCommandsLoader:load()
  local result, err = self.api:run("composer list --format=json")

  if err then
    return {}, Error:new("Failed to load composer commands"):wrap(err)
  end

  if result:failed() then
    return {}, Error:new("Failed to load composer commands: " .. result:prettyErrors())
  end

  return vim
    .iter(result:json().commands or {})
    :filter(function(command)
      return not command.hidden
    end)
    :totable()
end

return ComposerCommandsLoader
