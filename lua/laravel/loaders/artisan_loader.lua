local Class = require("laravel.class")

---@class laravel.dto.artisan_command
---@field name string

---@class laravel.loaders.artisan_loader
---@field api laravel.api
local ArtisanLoader = Class({ api = "laravel.api" })

---@return Promise<laravel.dto.artisan_command[]>
function ArtisanLoader:load()
  return self.api:send("artisan", { "list", "--format=json" }):thenCall(
    function(result)
      return vim
        .iter(result:json().commands or {})
        :filter(function(command)
          return not command.hidden
        end)
        :totable()
    end
  )
end

return ArtisanLoader
