---@type laravel.extensions.provider
local provider = {}

function provider.register(app, opts)
  app:addCommand("laravel.extensions.artisan_hub.hub_command")
end

function provider.boot(app)
  Laravel.extensions.artisan_hub = {
    toggle = function()
    end
  }
end

return provider
