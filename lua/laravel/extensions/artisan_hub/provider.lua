---@type laravel.extensions.provider
local provider = {}

function provider.register(app, opts)
  app:addCommand("laravel.extensions.artisan_hub.hub_command")
  app:addCommand("laravel.extensions.artisan_hub.add_command")

  app:singleton("laravel.extensions.artisan_hub.commands", opts.commands or {
    {
      name = "Serve",
      cmd = "artisan serve",
    },
    {
      name = "Assets",
      cmd = "npm run dev",
    },
    {
      name = "Pail",
      cmd = "artisan pail --timeout=0",
    },
    {
      name = "Logs",
      cmd = "tail -f -n 0 storage/logs/laravel.log",
      class = "laravel.extensions.artisan_hub.log_pty_command",
    },
  })
end

function provider.boot(app) end

return provider
