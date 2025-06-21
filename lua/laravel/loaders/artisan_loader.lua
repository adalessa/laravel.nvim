local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.dto.artisan_command
---@field name string

---@class laravel.loaders.artisan_loader
---@field api laravel.services.api
---@field new fun(self: laravel.loaders.artisan_loader, api: laravel.services.api): laravel.loaders.artisan_loader
local ArtisanLoader = Class({ api = "laravel.services.api" })

---@return laravel.dto.artisan_command[], laravel.error
function ArtisanLoader:load()
  local result, err = self.api:run("artisan list --format=json")

  if err then
    return {}, Error:new("Failed to get command list"):wrap(err)
  end

  if result:failed() then
    return {}, Error:new("Failed to load artisan commands: " .. result:prettyErrors())
  end

  return vim
    .iter(result:json().commands or {})
    :filter(function(command)
      return not command.hidden
    end)
    :totable()
end

return ArtisanLoader
